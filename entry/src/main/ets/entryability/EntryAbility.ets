import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { promptAction, window } from '@kit.ArkUI';

import app from '@system.app';
import { PreferencesUtil } from '../common/PreferenceUtil';
import { getToplistAlbum, getToplistArtist } from '../api/Toplist';
import { getNewAlbumList } from '../api/Album';
import { getPersonalizedCollection, getPersonalizedFM } from '../api/Personalized';
import { AccountProfile } from '../type/Account';
import Constant from '../common/Constant';
import Logger from '../common/Logger';
import { getUserPlaylist } from '../api/Playlist';
import { EventBus } from '../common/EventBus';
import { avPlayerManager } from '../common/AVPlayerManager';
import { downloadManager } from '../common/DownloadUtils';
import { TrackAndPrivilege } from '../type/Playlist';
import { globalPlaylist, PlayMode } from '../common/GlobalPlayListManager';
import { cacheManager } from '../common/CacheManager';
import { cover, getSupportedQuality, QualityLevel } from '../common/APIHelper';
import { checkIfLoved, getRecommendSongs, getSongLyric, getSongUrl, likeSong } from '../api/Song';
import { util } from '@kit.ArkTS';
import { avSession } from '@kit.AVSessionKit';
import { backgroundRunningManager } from '../common/BackgroundRunningManager';
import { audioFileSaver } from '../common/AudioFileSaver';

// 发现页数据加载
async function lookup() {
  try {
    const results = await Promise.all([
      getPersonalizedCollection(),
      getToplistArtist(),
      getNewAlbumList(),
      getToplistAlbum(),
      getRecommendSongs(),
    ]);

    const personalizedRes = results[0];
    const topArtistRes = results[1];
    const newAlbumRes = results[2];
    const topAlbumRes = results[3];

    const recommendSongsRes = results[4];

    AppStorage.setOrCreate('DailySong', recommendSongsRes.data.dailySongs);
    AppStorage.setOrCreate('PersonalizedPlaylist', personalizedRes.result);
    AppStorage.setOrCreate('ToplistArtistList', topArtistRes.list.artists);
    AppStorage.setOrCreate('NewAlbumList', newAlbumRes.albums);
    AppStorage.setOrCreate('TopListAlbumList', topAlbumRes.list);
  } catch (error) {
    Logger.warn("Init", error.message)
  }
}

// 音乐库也数据加载
async function library() {
  try {
    const results = await Promise.all([
      getUserPlaylist(),
    ]);

    const userPlayListRes = results[0];

    AppStorage.setOrCreate('UserPlayListDetail', userPlayListRes);
  } catch (error) {
    Logger.warn("Init", error.message)
  }
}

async function getLyric (id: number| string) {
  const res = await getSongLyric(id);
  AppStorage.setOrCreate("Lyrics", res)
  EventBus.send("LyricsUpdated")
}

// 记录当前正在缓存的歌曲ID
let currentCachingId: string | number | null = null;

async function cacheNextSong() {
  try {
    const nextTrack = globalPlaylist.getNext()
    if (!nextTrack) return

    const level = PreferencesUtil.get<QualityLevel>("defaultLevel") ?? "standard"
    const confirmLevel = getSupportedQuality(nextTrack.privilege.dlLevel as QualityLevel, level)
    const cache = cacheManager.get(`${nextTrack.track.id}_${confirmLevel}`)

    if (cache || nextTrack.privilege.st < 0) {
      return
    }

    currentCachingId = nextTrack.track.id;

    const url = (await getSongUrl(nextTrack.track.id)).data[0].url
    if (!url) return

    let fileName = url.split("/").pop() ?? `${util.generateRandomUUID()}`
    const index = fileName.indexOf("?")
    if (index > 0) {
      fileName = fileName.substring(0, index)
    }

    const path = await downloadManager.downloadFile({
      url,
      fileName
    })

    if (path) {
      cacheManager.set(`${nextTrack.track.id}_${confirmLevel}`, {
        id: nextTrack.track.id,
        level: confirmLevel,
        name: nextTrack.track.name,
        path,
        coverImgUrl: nextTrack.track.al.picUrl,
        artist: nextTrack.track.ar.map(item => item.name)
      })
    }
    currentCachingId = null;
  } catch (e) {
    currentCachingId = null;
    hilog.error(0x0000, 'CacheNextSong', 'Failed to cache next song: %{public}s', JSON.stringify(e))
  }
}

async function startPlaySong(track: TrackAndPrivilege) {
  try {
    // 如果当前正在缓存这首歌，等待缓存完成
    if (currentCachingId === track.track.id) {
      // 等待当前缓存任务完成
      await new Promise<boolean>(resolve => {
        const checkCache = setInterval(() => {
          if (!currentCachingId || currentCachingId !== track.track.id) {
            clearInterval(checkCache);
            resolve(true);
          }
        }, 100);
      });
    }

    const level = PreferencesUtil.get<QualityLevel>("defaultLevel") ?? "standard"
    const confirmLevel = getSupportedQuality(track.privilege.dlLevel as QualityLevel, level)
    const cache = cacheManager.get(`${track.track.id}_${confirmLevel}`)
    const autoCache = PreferencesUtil.get<boolean>("autoCache") ?? false;

    if (cache) {
      avPlayerManager.playByPath(cache.path)
      avPlayerManager.clearListener('onDurationChange')
      avPlayerManager.addListener('onDurationChange', async (duration: number) => {
        await avPlayerManager.updateAVMetadata({
          assetId: `track-${cache.id}`,
          duration: duration,
          title: cache.name,
          mediaImage: cover(cache.coverImgUrl, 512),
          artist: cache.artist.join("/")
        })
        AppStorage.setOrCreate("Track", track)
        getLyric(track.track.id)
        if (autoCache) {
          cacheNextSong()
        }
      })
      await backgroundRunningManager.stopBackgroundRunning();
      await backgroundRunningManager.startBackgroundRunning();
    } else {
      if (track.privilege.st < 0) {
        globalPlaylist.playNext()
        return
      }

      // 直接下载当前歌曲
      currentCachingId = track.track.id;
      const url = (await getSongUrl(track.track.id)).data[0].url
      let fileName = url.split("/").pop() ?? `${util.generateRandomUUID()}`
      const index = fileName.indexOf("?")
      if (index > 0) {
        fileName = fileName.substring(0, index)
      }
      const path = await downloadManager.downloadFile({
        url,
        fileName
      })

      currentCachingId = null;

      if (path) {
        avPlayerManager.playByPath(path)
        avPlayerManager.clearListener('onDurationChange')
        avPlayerManager.addListener('onDurationChange', async (duration: number) => {
          await avPlayerManager.updateAVMetadata({
            assetId: `track-${track.track.id}`,
            duration: duration,
            title: track.track.name,
            mediaImage: cover(track.track.al.picUrl, 512),
            artist: track.track.ar.map(item => item.name).join("/")
          })
          AppStorage.setOrCreate("Track", track)
          getLyric(track.track.id)
          if (autoCache) {
            cacheNextSong()
          }
        })
        await backgroundRunningManager.startBackgroundRunning();
        cacheManager.set(`${track.track.id}_${confirmLevel}`, {
          id: track.track.id,
          level: confirmLevel,
          name: track.track.name,
          path,
          coverImgUrl: track.track.al.picUrl,
          artist: track.track.ar.map(item => item.name)
        })
      } else {
        promptAction.showToast({
          message: "音乐资源获取失败!"
        })
        return
      }
    }

    const isLike = await checkIfLoved(track.track.id)
    const session = avPlayerManager.getSession();
    if (session) {
      session.setAVPlaybackState({
        isFavorite: isLike
      })
    }
    AppStorage.setOrCreate("TrackLike", track)

  } catch (e) {
    promptAction.showToast({
      message: "音乐资源获取失败!"
    })
  }
}

function getAuth() {
  const cookie = PreferencesUtil.get<string>('cookie');
  const signAt = PreferencesUtil.get<number>('signAt');
  const profile = PreferencesUtil.get<AccountProfile>("profile");
  const isValidCookie = cookie && signAt &&
    (Date.now() - signAt) < Constant.COOKIE_EXPIRY_DAYS * 24 * 60 * 60 * 1000;

  AppStorage.setOrCreate("ValidCookie", isValidCookie)
  AppStorage.setOrCreate('Profile', profile)
}

function cached() {
  AppStorage.setOrCreate("CacheList", cacheManager.getList())
  AppStorage.setOrCreate("CacheStats", cacheManager.getStats())
}

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    app.setImageRawDataCacheSize(100 * 1024 * 1024) // 设置解码前图片数据内存缓存上限为100MB
    PreferencesUtil.init(this.context);
    downloadManager.init(this.context)
    audioFileSaver.init(this.context)
    await avPlayerManager.init(this.context);

    let lastTrack: TrackAndPrivilege | null = null;

    cacheManager.initialize(this.context, {
      prefix: 'track_cache_'
    });

    EventBus.listen<string>("ViewChange", (key) => {
      if (!key) {
        return
      }
      if (key == "lookup") {
        lookup()
      } else if (key == "library") {
        library()
      } else if (key == "cached") {
        cached()
      }
    })

    EventBus.listen<TrackAndPrivilege>('CurrentChange', async (data) => {
      if (data !== undefined) {
        // 如果歌曲id并且不是单曲循环模式，则不重复播放
        if (lastTrack && lastTrack.track.id === data.track.id && globalPlaylist.playMode !== PlayMode.SINGLE) {
          return
        }
        lastTrack = data
        await avPlayerManager.stop()
        startPlaySong(data).then(() => {
          avPlayerManager.updatePlaybackState()
          EventBus.send("SongStartPlay")
        })
      }
    })

    EventBus.listen<void>('ToggleFavorite', async () => {
      const track = globalPlaylist.getCurrentSong()
      if (!track) {
        return;
      }
      const isLike = await checkIfLoved(track.track.id)
      await likeSong(track.track.id, !isLike);
      const session = avPlayerManager.getSession();
      if (session) {
        session.setAVPlaybackState({
          isFavorite: !isLike
        })
      }
      AppStorage.setOrCreate("TrackLike", !isLike)
    })

    EventBus.listen<PlayMode>('PlayModeSet', async (playMode) => {
      const session = avPlayerManager.getSession();
      let mode = avSession.LoopMode.LOOP_MODE_LIST;
      switch (playMode) {
        case PlayMode.SEQUENCE:
          mode = avSession.LoopMode.LOOP_MODE_SEQUENCE
          break;
        case PlayMode.RANDOM:
          mode = avSession.LoopMode.LOOP_MODE_SHUFFLE
          break;
        case PlayMode.LOOP:
          mode = avSession.LoopMode.LOOP_MODE_LIST
          break;
        case PlayMode.SINGLE:
          mode = avSession.LoopMode.LOOP_MODE_SINGLE
          break;
      }
      if (session) {
        session.setAVPlaybackState({
          loopMode: mode
        })
      }
    })
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    const notFirstStart = PreferencesUtil.get<boolean>("notFirstStart")

    if (!notFirstStart) {
      PreferencesUtil.put("notFirstStart", true)
      PreferencesUtil.put("defaultLevel", "standard")
      windowStage.loadContent('pages/Splash', (err) => {
        if (err.code) {
          hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
          return;
        }
        hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
      });
      return
    }

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');

      // 获取用户登录信息
      getAuth()

      // 初始化数据
      lookup()
    });

  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
