import { Privilege, TrackAndPrivilege, Track } from "../type/Playlist"
import { EventBus } from "./EventBus"
import { PreferencesUtil } from "./PreferenceUtil"
import { promptAction, router } from "@kit.ArkUI"
import { getPersonalizedFM } from "../api/Personalized"
import Logger from "./Logger"

const TAG= "GlobalPlayListManager"

export interface ChangeSong {
  song: TrackAndPrivilege,
  pause: number
}

enum STORAGE_KEYS {
  PLAY_MODE = 'playlist_play_mode',
  PLAYLIST = 'playlist_tracks',
  CURRENT_INDEX = 'current_index',
  TYPE = 'play_type'
}

export interface PlaylistChangeEvent {
  playlist: Array<TrackAndPrivilege>
  type: PlaylistChangeType
}

export enum PlaylistChangeType {
  ADD = 'ADD',
  REMOVE = 'REMOVE',
  CLEAR = 'CLEAR',
  MOVE = 'MOVE',
  OVERWRITE = 'OVERWRITE'
}

export enum PlayMode {
  SEQUENCE = 'SEQUENCE',
  RANDOM = 'RANDOM',
  LOOP = 'LOOP',
  SINGLE = 'SINGLE'
}

export enum PlayAction {
  NEXT = "NEXT",
  PRE = "PRE"
}

export enum PlayType {
  NORMAL = 0, // 普通播放
  PERSONAL_FM = 1, // 私人FM
}

class GlobalPlaylist {
  private static instance: GlobalPlaylist | null = null
  private playlist: Array<TrackAndPrivilege> = []
  private _currentIndex: number = -1
  private debounceTimer: number | null = null
  private readonly DEBOUNCE_DELAY: number = 333
  private _playMode: PlayMode = PlayMode.LOOP
  private randomQueue: number[] = []

  private lastAction = PlayAction.NEXT

  private _playType: PlayType = PlayType.NORMAL
  private isLoadingFM: boolean = false

  private constructor() {
  }

  public async loadPersistedData() {
    if (!PreferencesUtil.isInitialized()) {
      return;
    }

    // 加载播放模式
    const persistedMode = await PreferencesUtil.getAsync<string>(STORAGE_KEYS.PLAY_MODE, PlayMode.LOOP);
    this._playMode = persistedMode as PlayMode;
    EventBus.send("PlayModeSet", this._playMode);

    // // 加载播放类型 暂时不做任何动作
    // const playType = await PreferencesUtil.getAsync<number>(STORAGE_KEYS.TYPE, PlayType.NORMAL);
    // this._playType = playType as PlayType;
    // EventBus.send("PlayTypeChange", this._playType);

    // 根据播放类型决定如何加载播放列表
    if (this._playType === PlayType.PERSONAL_FM) {
      // // 提示用户
      // promptAction.showToast({ message: "已进入私人FM模式" })
      // // FM模式下，直接加载新的FM歌曲
      // await this.startPersonalFM()
      // // // FM模式强制使用顺序播放
      // // this._playMode = PlayMode.SEQUENCE;
      // // EventBus.send("PlayModeSet", this._playMode);
      // 暂时不做然后动作
    } else {
      // 普通模式，加载持久化的播放列表
      const persistedPlaylist = await PreferencesUtil.getAsync<string>(STORAGE_KEYS.PLAYLIST, '[]');
      try {
        this.playlist = JSON.parse(persistedPlaylist);
      } catch (e) {
        Logger.error(TAG, `Failed to parse persisted playlist: ${e.message}`);
        this.playlist = [];
      }
    }

    // 加载当前播放索引
    this._currentIndex = await PreferencesUtil.getAsync<number>(STORAGE_KEYS.CURRENT_INDEX, -1);

    // 随机模式下生成随机队列
    if (this._playMode === PlayMode.RANDOM && this._playType !== PlayType.PERSONAL_FM) {
      this.generateRandomQueue();
    }

    // 如果播放列表非空，发送播放列表变更事件
    if (this.playlist.length > 0) {
      this.emitPlaylistChange(PlaylistChangeType.OVERWRITE);
    }

    // 触发当前歌曲变更事件
    this.debouncedEmitCurrentChange(this.getCurrentSong(), 1);

    Logger.info(TAG, `Persisted data loaded - Mode: ${this._playMode}, Type: ${this._playType}, ` +
      `Playlist Length: ${this.playlist.length}, Current Index: ${this._currentIndex}`);
  }

  public static getInstance(): GlobalPlaylist {
    if (GlobalPlaylist.instance === null) {
      GlobalPlaylist.instance = new GlobalPlaylist()
    }
    return GlobalPlaylist.instance
  }

  public get playMode() {
    return this._playMode
  }

  private debouncedEmitCurrentChange(song: TrackAndPrivilege | undefined, pause = 0): void {
    if (this.debounceTimer !== null) {
      clearTimeout(this.debounceTimer)
    }

    this.debounceTimer = setTimeout(() => {
      if (song !== undefined) {
        EventBus.send('CurrentChange', {
          song,
          pause
        } as ChangeSong)
      }
      this.debounceTimer = null
    }, this.DEBOUNCE_DELAY)
  }

  private emitPlaylistChange(type: PlaylistChangeType): void {
    EventBus.send("PlayListChange", type)
    PreferencesUtil.putAsync(STORAGE_KEYS.PLAYLIST, JSON.stringify(this.playlist))
  }

  public setCurrentIndex(value: number): void {
    this._currentIndex = value
    PreferencesUtil.putAsync(STORAGE_KEYS.CURRENT_INDEX, value)
    this.debouncedEmitCurrentChange(this.getCurrentSong())
  }

  private getCurrentIndexValue(): number {
    return this._currentIndex
  }

  private generateRandomQueue(): void {
    const length = this.playlist.length
    this.randomQueue = []
    for (let i = 0; i < length; i++) {
      this.randomQueue.push(i)
    }

    for (let i = length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1))
      const temp = this.randomQueue[i]
      this.randomQueue[i] = this.randomQueue[j]
      this.randomQueue[j] = temp
    }
  }

  private getNextIndex(): number {
    const currentIndex = this.getCurrentIndexValue()
    const playlistLength = this.playlist.length

    switch (this._playMode) {
      case PlayMode.SEQUENCE:
        if (currentIndex === playlistLength - 1) {
          return -1
        }
        return (currentIndex + 1) % playlistLength
      case PlayMode.LOOP:
        return (currentIndex + 1) % playlistLength
      case PlayMode.SINGLE:
        return currentIndex
      case PlayMode.RANDOM:
        if (this.randomQueue.length === 0) {
          this.generateRandomQueue()
        }
        const currentRandomIndex = this.findIndexInRandomQueue(currentIndex)
        return this.randomQueue[(currentRandomIndex + 1) % this.randomQueue.length]
      default:
        return -1
    }
  }

  private findIndexInRandomQueue(currentIndex: number): number {
    for (let i = 0; i < this.randomQueue.length; i++) {
      if (this.randomQueue[i] === currentIndex) {
        return i
      }
    }
    return -1
  }

  private getPreviousIndex(): number {
    const currentIndex = this.getCurrentIndexValue()
    const playlistLength = this.playlist.length

    switch (this._playMode) {
      case PlayMode.SEQUENCE:
      case PlayMode.LOOP:
        return (currentIndex - 1 + playlistLength) % playlistLength
      case PlayMode.SINGLE:
        return currentIndex
      case PlayMode.RANDOM:
        if (this.randomQueue.length === 0) {
          this.generateRandomQueue()
        }
        const currentRandomIndex = this.findIndexInRandomQueue(currentIndex)
        return this.randomQueue[(currentRandomIndex - 1 + this.randomQueue.length) % this.randomQueue.length]
      default:
        return -1
    }
  }

  public setPlayMode(mode: PlayMode): void {
    this._playMode = mode
    PreferencesUtil.putAsync(STORAGE_KEYS.PLAY_MODE, mode)
    if (mode === PlayMode.RANDOM) {
      this.generateRandomQueue()
    }
    EventBus.send("PlayModeSet", mode)
  }

  public getPlayMode(): PlayMode {
    return this._playMode
  }

  public getPlaylist(): Array<TrackAndPrivilege> {
    return this.playlist
  }

  public addSong(song: TrackAndPrivilege): void {
    this.playlist.push(song)
    if (this._playMode === PlayMode.RANDOM) {
      this.generateRandomQueue()
    }
    this.emitPlaylistChange(PlaylistChangeType.ADD)
  }

  public insertSong(song: TrackAndPrivilege, index: number): void {
    if (index < 0 || index > this.playlist.length) {
      throw new Error('Invalid index')
    }
    this.playlist.splice(index, 0, song)
    if (index <= this.getCurrentIndexValue()) {
      this.setCurrentIndex(this.getCurrentIndexValue() + 1)
    }
    if (this._playMode === PlayMode.RANDOM) {
      this.generateRandomQueue()
    }
    this.emitPlaylistChange(PlaylistChangeType.ADD)
  }

  public removeSong(id: string | number): void {
    const index = this.findSongIndexById(id)
    if (index !== -1) {
      this.playlist.splice(index, 1)
      const currentIndex = this.getCurrentIndexValue()
      if (index < currentIndex) {
        this.setCurrentIndex(currentIndex - 1)
      } else if (index === currentIndex) {
        this.setCurrentIndex(this.playlist.length > 0 ? 0 : -1)
      }
      if (this._playMode === PlayMode.RANDOM) {
        this.generateRandomQueue()
      }
      this.emitPlaylistChange(PlaylistChangeType.REMOVE)
    }
  }

  private findSongIndexById(id: string | number): number {
    for (let i = 0; i < this.playlist.length; i++) {
      if (this.playlist[i].track.id === id) {
        return i
      }
    }
    return -1
  }

  public clear(): void {
    if (this._playType === PlayType.PERSONAL_FM) {
      // FM模式下改为停止FM
      this.stopPersonalFM();
      return;
    }

    this.playlist = [];
    this.setCurrentIndex(-1);
    this.randomQueue = [];
    this.emitPlaylistChange(PlaylistChangeType.CLEAR);
    PreferencesUtil.putAsync(STORAGE_KEYS.PLAYLIST, '[]');
    PreferencesUtil.putAsync(STORAGE_KEYS.CURRENT_INDEX, -1);
  }

  // 获取播放类型
  public get playType(): PlayType {
    return this._playType;
  }

  // 设置播放类型
  private async setPlayType(type: PlayType): Promise<void> {
    this._playType = type;
    PreferencesUtil.putAsync(STORAGE_KEYS.TYPE, type);

    // 如果切换到FM模式，立即加载FM歌曲
    if (type === PlayType.PERSONAL_FM) {
      await this.loadFMSongs();
    }

    EventBus.send("PlayTypeChange", type);
  }

  // 开启私人FM模式
  public async startPersonalFM(): Promise<void> {
    if (this._playType === PlayType.PERSONAL_FM) {
      return;
    }
    promptAction.showToast({ message: "已进入私人FM模式" })

    // 清空当前播放列表
    this.clear();
    await this.setPlayType(PlayType.PERSONAL_FM);
    // // 强制设置为顺序播放
    // this.setPlayMode(PlayMode.SEQUENCE);

    animateTo({ duration: 0 }, () => {
      AppStorage.setOrCreate("Track", globalPlaylist.getCurrentSong())
    })
    globalPlaylist.setCurrentIndex(0)
    router.pushUrl({ url: "pages/Playing" })
  }

  // 退出私人FM模式
  public async stopPersonalFM(): Promise<void> {
    if (this._playType !== PlayType.PERSONAL_FM) {
      return;
    }

    this.clear();
    await this.setPlayType(PlayType.NORMAL);
  }

  // 加载FM歌曲
  private async loadFMSongs(): Promise<void> {
    if (this.isLoadingFM || this._playType !== PlayType.PERSONAL_FM) {
      return;
    }

    try {
      this.isLoadingFM = true;
      const response = await getPersonalizedFM();
      if (response?.data) {
        const fmSongs = response.data.map(song => {
          const track = new TrackAndPrivilege();
          track.track = song as ESObject as Track;
          track.privilege = song.privilege as ESObject as Privilege;
          return track;
        });

        // 添加到当前播放列表末尾
        this.playlist.push(...fmSongs);
        this.emitPlaylistChange(PlaylistChangeType.ADD);
      }
    } catch (error) {
      Logger.error(TAG, `Failed to load FM songs: ${error}`);
    } finally {
      this.isLoadingFM = false;
    }
  }

  // 检查是否需要加载更多FM歌曲
  private async checkAndLoadMoreFM(): Promise<void> {
    if (this._playType !== PlayType.PERSONAL_FM) {
      return;
    }

    const remainingSongs = this.playlist.length - (this.getCurrentIndexValue() + 1);
    if (remainingSongs <= 1) {  // 当剩余歌曲少于等于1首时，加载更多
      await this.loadFMSongs();
    }
  }

  public async overwrite(songs: Array<TrackAndPrivilege>, index = 0): Promise<void> {
    // 如果是FM模式，先退出并提示
    if (this._playType === PlayType.PERSONAL_FM) {
      await this.stopPersonalFM();
      promptAction.showToast({
        message: '已退出私人FM模式' });
    }

    this.playlist = songs;
    this.setCurrentIndex(songs.length > index ? index : -1);
    if (this._playMode === PlayMode.RANDOM) {
      this.generateRandomQueue();
    }
    this.emitPlaylistChange(PlaylistChangeType.OVERWRITE);
  }


  public get length(): number {
    return this.playlist.length
  }

  public findSongById(id: string | number): TrackAndPrivilege | undefined {
    for (const song of this.playlist) {
      if (song.track.id === id) {
        return song
      }
    }
    return undefined
  }

  public moveSong(fromIndex: number, toIndex: number): void {
    if (
      fromIndex < 0 ||
        fromIndex >= this.playlist.length ||
        toIndex < 0 ||
        toIndex >= this.playlist.length
    ) {
      throw new Error('Invalid index')
    }

    const song = this.playlist[fromIndex]
    this.playlist.splice(fromIndex, 1)
    this.playlist.splice(toIndex, 0, song)

    const currentIndex = this.getCurrentIndexValue()
    if (fromIndex === currentIndex) {
      this.setCurrentIndex(toIndex)
    } else if (fromIndex < currentIndex && toIndex >= currentIndex) {
      this.setCurrentIndex(currentIndex - 1)
    } else if (fromIndex > currentIndex && toIndex <= currentIndex) {
      this.setCurrentIndex(currentIndex + 1)
    }

    if (this._playMode === PlayMode.RANDOM) {
      this.generateRandomQueue()
    }
    this.emitPlaylistChange(PlaylistChangeType.MOVE)
  }

  public getCurrentSong(): TrackAndPrivilege | undefined {
    const currentIndex = this.getCurrentIndexValue()
    if (currentIndex === -1 || this.playlist.length === 0) {
      return undefined
    }
    return this.playlist[currentIndex]
  }

  public async playNext(): Promise<TrackAndPrivilege | undefined> {
    if (this.playlist.length === 0) {
      return undefined;
    }

    if (this._playType === PlayType.PERSONAL_FM) {
      await this.checkAndLoadMoreFM();
    }

    if (this.getCurrentIndexValue() === -1) {
      this.setCurrentIndex(0);
    } else {
      const nextIndex = this.getNextIndex();
      if (nextIndex === -1) {
        return undefined;
      }
      this.setCurrentIndex(nextIndex);
    }

    this.lastAction = PlayAction.NEXT;
    return this.getCurrentSong();
  }

  public playPrevious(): TrackAndPrivilege | undefined {
    if (this.playlist.length === 0) {
      return undefined
    }
    if (this.getCurrentIndexValue() === -1) {
      this.setCurrentIndex(this.playlist.length - 1)
    } else {
      const previousIndex = this.getPreviousIndex()
      if (previousIndex === -1) {
        return undefined
      }
      this.setCurrentIndex(previousIndex)
    }
    this.lastAction = PlayAction.PRE
    return this.getCurrentSong()
  }

  public getLastAction() {
    return this.lastAction
  }

  public setCurrentSongIndex(index: number): TrackAndPrivilege | undefined {
    if (index < 0 || index >= this.playlist.length) {
      throw new Error('Invalid index')
    }
    this.setCurrentIndex(index)
    return this.getCurrentSong()
  }

  public getCurrentIndex(): number {
    return this.getCurrentIndexValue()
  }

  public insertTop(song: TrackAndPrivilege): void {
    if (this.isExist(song)) {
      return
    }
    this.insertSong(song, 0)
    this.setCurrentSongIndex(0)
  }

  public destroy(): void {
    if (this.debounceTimer !== null) {
      clearTimeout(this.debounceTimer);
      this.debounceTimer = null;
    }
    PreferencesUtil.putAsync(STORAGE_KEYS.PLAY_MODE, this._playMode);
    PreferencesUtil.putAsync(STORAGE_KEYS.PLAYLIST, JSON.stringify(this.playlist));
    PreferencesUtil.putAsync(STORAGE_KEYS.CURRENT_INDEX, this._currentIndex);
    PreferencesUtil.putAsync(STORAGE_KEYS.TYPE, this._playType);
  }

  public isExist(song: TrackAndPrivilege): boolean {
    return this.playlist.some(item => item.track.id === song.track.id)
  }

  public switchPlayMode(): PlayMode {
    switch (this._playMode) {
      case PlayMode.LOOP:
        this.setPlayMode(PlayMode.SINGLE)
        break
      case PlayMode.SINGLE:
        this.setPlayMode(PlayMode.RANDOM)
        break
      case PlayMode.RANDOM:
        this.setPlayMode(PlayMode.SEQUENCE)
        break
      case PlayMode.SEQUENCE:
        this.setPlayMode(PlayMode.LOOP)
        break
    }
    return this._playMode
  }

  public getNext() {
    const index = this.getNextIndex()
    if (index === -1) {
      return undefined
    }
    return this.playlist[index]
  }

  public insertOrMoveNext(song: TrackAndPrivilege): boolean {
    const targetIndex = this.getCurrentIndex() + 1
    const existingIndex = this.findSongIndexById(song.track.id)

    if (existingIndex !== -1) {
      if (existingIndex === targetIndex) {
        return false
      }

      if (existingIndex > targetIndex) {
        this.moveSong(existingIndex, targetIndex)
      } else {
        this.moveSong(existingIndex, targetIndex - 1)
      }
    } else {
      this.insertSong(song, targetIndex)
    }

    return true
  }
}

const globalPlaylist = GlobalPlaylist.getInstance()

export { globalPlaylist }