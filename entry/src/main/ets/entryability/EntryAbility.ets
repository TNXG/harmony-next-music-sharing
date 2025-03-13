import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { promptAction, window } from '@kit.ArkUI';
import { fileIo as fs } from '@kit.CoreFileKit';

import app from '@system.app';
import { PreferencesUtil } from '../common/PreferenceUtil';
import { getToplistAlbum, getToplistArtist } from '../api/Toplist';
import { getNewAlbumList } from '../api/Album';
import { getPersonalizedCollection } from '../api/Personalized';
import { AccountProfile } from '../type/Account';
import Constant from '../common/Constant';
import Logger from '../common/Logger';
import { getUserPlaylist } from '../api/Playlist';
import { EventBus } from '../common/EventBus';
import { avPlayerManager } from '../common/AVPlayerManager';
import { downloadManager } from '../common/DownloadUtils';
import { TrackAndPrivilege } from '../type/Playlist';
import { ChangeSong, globalPlaylist, PlayAction, PlayMode } from '../common/GlobalPlayListManager';
import { cacheManager } from '../common/CacheManager';
import { cover, getSupportedQuality, isTrackPlayable, QualityLevel } from '../common/APIHelper';
import { checkIfLoved, getRecommendSongs, getSongLyric, getSongUrl, likeSong } from '../api/Song';
import { util } from '@kit.ArkTS';
import { avSession } from '@kit.AVSessionKit';
import { backgroundRunningManager } from '../common/BackgroundRunningManager';
import { audioFileSaver } from '../common/AudioFileSaver';
import { SongCache } from '../type/Song';
import { LyricParser } from '../common/LyricParser';

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

    AppStorage.setOrCreate('PersonalizedPlaylist', personalizedRes.result);
    AppStorage.setOrCreate('ToplistArtistList', topArtistRes.list.artists);
    AppStorage.setOrCreate('NewAlbumList', newAlbumRes.albums);
    AppStorage.setOrCreate('TopListAlbumList', topAlbumRes.list);
    AppStorage.setOrCreate('DailySong', recommendSongsRes.data.dailySongs);
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

async function getLyric(id: number | string) {
  const res = await getSongLyric(id);
  AppStorage.setOrCreate("Lyrics", res)
  EventBus.send("LyricsUpdated")

  return LyricParser.parseLyrics(res)
}

// 记录当前正在缓存的歌曲ID
let currentCachingId: string | number | null = null;

async function checkCacheFileExists(cache: SongCache): Promise<boolean> {
  if (!cache || !cache.path) {
    return false;
  }
  try {
    await fs.access(cache.path);
    return true;
  } catch (e) {
    // 如果文件不存在，删除无效的缓存记录
    cacheManager.remove(`${cache.id}_${cache.level}`);
    return false;
  }
}

async function cacheNextSong() {
  const nextTrack = globalPlaylist.getNext()
  if (!nextTrack) {
    return
  }
  const playableResult = isTrackPlayable(nextTrack)
  try {

    const level = PreferencesUtil.get<QualityLevel>("defaultLevel") ?? "standard"
    const confirmLevel = getSupportedQuality(nextTrack.privilege.dlLevel as QualityLevel, level)
    const cache = cacheManager.get(`${nextTrack.track.id}_${confirmLevel}`)

    // 增加缓存文件存在性检查
    if (cache) {
      const exists = await checkCacheFileExists(cache);
      if (exists) {
        return;
      }
      // 如果文件不存在，继续执行下载逻辑
    }

    if (!playableResult.isPlayable) {
      return
    }

    currentCachingId = nextTrack.track.id;

    const url = (await getSongUrl(nextTrack.track.id)).data[0].url
    if (!url) {
      return
    }

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
      const cache = new SongCache()
      cache.id = nextTrack.track.id
      cache.level = confirmLevel
      cache.name = nextTrack.track.name
      cache.path = path
      cache.coverImgUrl = nextTrack.track.al.picUrl
      cache.artist = nextTrack.track.ar.map(item => item.name)

      cacheManager.set(`${nextTrack.track.id}_${confirmLevel}`, cache)
    }
    currentCachingId = null;
  } catch (e) {
    currentCachingId = null;
    hilog.error(0x0000, 'CacheNextSong', 'Failed to cache next song: %{public}s', JSON.stringify(e))
    if (playableResult.ignoreGray) {
      promptAction.showToast({
        message: "音乐资源获取失败，可能是因为歌曲已下架!"
      })
    }
  }
}

async function startPlaySong(song: ChangeSong) {
  const track = song.song
  try {
    if (currentCachingId === track.track.id) {
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
    Logger.info("CacheNextSong", `Next song quality level: ${level}`)
    const confirmLevel = getSupportedQuality(track.privilege.dlLevel as QualityLevel, level)

    Logger.info("CacheNextSong", `Next song confirm level: ${confirmLevel}`)
    const cache = cacheManager.get(`${track.track.id}_${confirmLevel}`)
    const autoCache = PreferencesUtil.get<boolean>("autoCache") ?? false;

    AppStorage.setOrCreate("Lyrics", null)
    EventBus.send("LyricsUpdated")

    if (cache) {
      // 增加缓存文件存在性检查
      const exists = await checkCacheFileExists(cache);
      if (!exists) {
        // 如果缓存文件不存在，走下载逻辑
        return await handleSongDownload(track, song.pause, confirmLevel, autoCache);
      }

      // 输出一下保存的缓存信息
      Logger.info("CacheNextSong", `Cached song: ${JSON.stringify(cache)}`)

      await avPlayerManager.playByPath(cache.path, song.pause)
      avPlayerManager.clearListener('onDurationChange')
      avPlayerManager.addListener('onDurationChange', async (duration: number) => {
        await avPlayerManager.updateAVMetadata({
          assetId: `track-${cache.id}`,
          duration: duration,
          title: cache.name,
          mediaImage: cover(cache.coverImgUrl, 512),
          artist: cache.artist.join("/"),
          lyric: LyricParser.convertToLRC(await getLyric(cache.id))
        }, true)
        AppStorage.setOrCreate("Track", track)
        if (autoCache) {
          cacheNextSong()
        }
      })
    } else {
      Logger.info("DownloadUtils", `No cache found for song: ${track.track.id}`)
      await handleSongDownload(track, song.pause, confirmLevel, autoCache);
    }

    const isLike = await checkIfLoved(track.track.id)
    const session = avPlayerManager.getSession();
    if (session) {
      session.setAVPlaybackState({
        isFavorite: isLike
      })
    }
    AppStorage.setOrCreate("TrackLike", isLike)

  } catch (e) {
    Logger.warn("RequestUtil", e.message)
    promptAction.showToast({
      message: "音乐资源获取失败!"
    })
  }
}

// 抽取下载和播放逻辑为独立函数
async function handleSongDownload(
  track: TrackAndPrivilege,
  pause: number,
  confirmLevel: QualityLevel,
  autoCache: boolean
) {
  const playableResult = isTrackPlayable(track)
  if (!playableResult.isPlayable) {
    if (globalPlaylist.getLastAction() == PlayAction.NEXT) {
      globalPlaylist.playNext()
    } else {
      globalPlaylist.playPrevious()
    }
    return
  }

  currentCachingId = track.track.id;
  const trackInfo = (await getSongUrl(track.track.id)).data[0]
  const url = trackInfo.url
  const trueSize = trackInfo.size
  if (!url) {
    currentCachingId = null;
    promptAction.showToast({
      message: "音乐资源获取失败!"
    })
    return;
  }

  let fileName = url.split("/").pop() ?? `${util.generateRandomUUID()}`
  const index = fileName.indexOf("?")
  if (index > 0) {
    fileName = fileName.substring(0, index)
  }

  const filePath = `${getContext()!.filesDir}/${fileName}`;
  Logger.info("DownloadUtils", `Downloading song: ${track.track.id}, url: ${url}, path: ${filePath}, size: ${trueSize}`)

  await avPlayerManager.stop()

  // 不等待下载完成,直接开始下载
  downloadManager.downloadFile({
    url,
    fileName
  });

  // 等待文件创建
  await new Promise<void>((resolve) => {
    const checkFile = setInterval(async () => {
      try {
        const stats = await fs.stat(filePath);
        const progress = (stats.size / trueSize) * 100;
        if (progress >= 10) {
          clearInterval(checkFile);
          resolve();
        }
      } catch (err) {
        // 文件还未创建,继续等待
      }
    }, 100);
  });


  // 文件已创建,开始播放
  Logger.info("DownloadUtils", `Downloaded song: ${track.track.id}, path: ${filePath}`)
  try {
    await avPlayerManager.playByPath(filePath, pause, trueSize)
  } catch (e) {
    Logger.warn("DownloadUtils", e.message)
  }


  // 后续逻辑保持不变
  avPlayerManager.clearListener('onDurationChange')
  avPlayerManager.addListener('onDurationChange', async (duration: number) => {
    await avPlayerManager.updateAVMetadata({
      assetId: `track-${track.track.id}`,
      duration: duration,
      title: track.track.name,
      mediaImage: cover(track.track.al.picUrl, 512),
      artist: track.track.ar.map(item => item.name).join("/"),
      lyric: LyricParser.convertToLRC(await getLyric(cache.id))
    }, true)
    AppStorage.setOrCreate("Track", track)
    if (autoCache) {
      cacheNextSong()
    }
  })

  currentCachingId = null;

  const cache = new SongCache()
  cache.id = track.track.id
  cache.level = confirmLevel
  cache.name = track.track.name
  cache.path = filePath
  cache.coverImgUrl = track.track.al.picUrl
  cache.artist = track.track.ar.map(item => item.name)

  cacheManager.set(`${track.track.id}_${confirmLevel}`, cache)
}

function getAuth() {
  const cookie = PreferencesUtil.get<string>('cookie');
  const signAt = PreferencesUtil.get<number>('signAt');
  const profile = PreferencesUtil.get<AccountProfile>("profile");
  const isValidCookie = cookie && signAt &&
    (Date.now() - signAt) < Constant.COOKIE_EXPIRY_DAYS * 24 * 60 * 60 * 1000;

  AppStorage.setOrCreate("ValidCookie", isValidCookie)
  AppStorage.setOrCreate('Profile', profile)

  // 输出调试一下
  hilog.info(0x0000, 'testTag', 'cookie: %{public}s, signAt: %{public}s, profile: %{public}s', cookie, signAt,
    JSON.stringify(profile));

  // 对上一个版本的兼容，如果用户已经登录了，但是没有设置自定义 URL，设置默认
  if (PreferencesUtil.isInitialized()) {
    const biliCookies = PreferencesUtil.get<string>('biliCookies');
    if (isValidCookie && !biliCookies) {
      hilog.info(0x0000, 'testTag', '用户已登录，但未设置自定义 URL，设置默认 URL');
      PreferencesUtil.put('biliCookies', Constant.BASE_URL);
    }
  }
}

function cached() {
  AppStorage.setOrCreate("CacheList", cacheManager.getList())
  AppStorage.setOrCreate("CacheStats", cacheManager.getStats())
}

export default class EntryAbility extends UIAbility {
  private shutdownTimer: number | null = null;
  private shutdownTime: number | null = null;

  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    app.setImageRawDataCacheSize(100 * 1024 * 1024) // 设置解码前图片数据内存缓存上限为100MB
    PreferencesUtil.init(this.context);
    downloadManager.init(this.context)
    audioFileSaver.init(this.context)
    await avPlayerManager.init(this.context);

    avPlayerManager.addListener("onPlay", async () => {
      await backgroundRunningManager.startBackgroundRunning();
    })

    avPlayerManager.addListener("onPause", async () => {
      await backgroundRunningManager.startBackgroundRunning();
    })

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

    let playTimer: number | null = null;

    EventBus.listen<ChangeSong>('CurrentChange', async (changed) => {
      if (changed !== undefined) {
        const data = changed.song;
        // 如果歌曲id并且不是单曲循环模式，则不重复播放
        if (lastTrack && lastTrack.track.id === data.track.id && globalPlaylist.playMode !== PlayMode.SINGLE) {
          return;
        }
        lastTrack = data;
        await avPlayerManager.stop();

        // 清除之前的定时器
        if (playTimer !== null) {
          clearTimeout(playTimer);
        }

        // 设置新的定时器
        playTimer = setTimeout(() => {
          startPlaySong(changed).then(() => {
            avPlayerManager.updatePlaybackState();
          });
        }, 300);
      }
    });

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


    // 添加定时关闭事件监听
    EventBus.listen<number | null>('SetTimer', async (minutes) => {
      // 如果传入 null 或 0，取消定时
      if (!minutes) {
        if (this.shutdownTimer) {
          clearTimeout(this.shutdownTimer);
          this.shutdownTimer = null;
        }
        this.shutdownTime = null;
        EventBus.send('TimerUpdated', null);
        promptAction.showToast({
          message: "已取消定时关闭",
          duration: 2000,
          bottom: 64
        });
        return;
      }

      // 清除可能存在的旧定时器
      if (this.shutdownTimer) {
        clearTimeout(this.shutdownTimer);
      }

      // 设置新的定时器
      const timeInMs = minutes * 60 * 1000;
      this.shutdownTime = Date.now() + timeInMs;

      this.shutdownTimer = setTimeout(async () => {
        // 停止播放
        await avPlayerManager.pause();
        // 更新状态
        this.shutdownTimer = null;
        this.shutdownTime = null;
        EventBus.send('TimerUpdated', null);
        // 发送通知
        promptAction.showToast({
          message: "定时关闭已执行",
          duration: 2000,
          bottom: 64
        });
      }, timeInMs);

      // 通知 UI 更新定时状态
      EventBus.send('TimerUpdated', this.shutdownTime);

      // 显示设置成功提示
      promptAction.showToast({
        message: `已设置 ${minutes} 分钟后关闭`,
      });
    });

    // 添加查询定时状态事件监听
    EventBus.listen<void>('GetTimerStatus', () => {
      EventBus.send('TimerUpdated', this.shutdownTime);
    });

    await globalPlaylist.loadPersistedData()
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
    // 清理定时器
    if (this.shutdownTimer) {
      clearTimeout(this.shutdownTimer);
      this.shutdownTimer = null;
    }
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    const confirmPolicy = PreferencesUtil.get<boolean>("confirmPolicy")

    if (!confirmPolicy) {
      PreferencesUtil.put("defaultLevel", "standard")
      windowStage.loadContent('pages/Policy', (err) => {
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

      lookup()

      library()
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
