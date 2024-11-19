import { TrackAndPrivilege } from "../type/Playlist"
import { EventBus } from "./EventBus"

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

class GlobalPlaylist {
  private static instance: GlobalPlaylist | null = null
  private playlist: Array<TrackAndPrivilege> = []
  private _currentIndex: number = -1
  private debounceTimer: number | null = null
  private readonly DEBOUNCE_DELAY: number = 333
  private _playMode: PlayMode = PlayMode.LOOP
  private randomQueue: number[] = []

  private constructor() {}

  public static getInstance(): GlobalPlaylist {
    if (GlobalPlaylist.instance === null) {
      GlobalPlaylist.instance = new GlobalPlaylist()
    }
    return GlobalPlaylist.instance
  }

  public get playMode() {
    return this._playMode
  }

  private debouncedEmitCurrentChange(song: TrackAndPrivilege | undefined): void {
    if (this.debounceTimer !== null) {
      clearTimeout(this.debounceTimer)
    }

    this.debounceTimer = setTimeout(() => {
      if (song !== undefined) {
        EventBus.send('CurrentChange', song)
      }
      this.debounceTimer = null
    }, this.DEBOUNCE_DELAY)
  }

  private emitPlaylistChange(type: PlaylistChangeType): void {
    EventBus.send("PlayListChange", type)
  }

  public setCurrentIndex(value: number): void {
    this._currentIndex = value
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

    // Fisher-Yates 洗牌算法
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
    this.playlist = []
    this.setCurrentIndex(-1)
    this.randomQueue = []
    this.emitPlaylistChange(PlaylistChangeType.CLEAR)
  }

  public overwrite(songs: Array<TrackAndPrivilege>): void {
    this.playlist = songs
    this.setCurrentIndex(songs.length > 0 ? 0 : -1)
    if (this._playMode === PlayMode.RANDOM) {
      this.generateRandomQueue()
    }
    this.emitPlaylistChange(PlaylistChangeType.OVERWRITE)
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

  public playNext(): TrackAndPrivilege | undefined {
    if (this.playlist.length === 0) {
      return undefined
    }
    if (this.getCurrentIndexValue() === -1) {
      this.setCurrentIndex(0)
    } else {
      const nextIndex = this.getNextIndex()
      if (nextIndex === -1) {
        return undefined
      }
      this.setCurrentIndex(nextIndex)
    }
    return this.getCurrentSong()
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
    return this.getCurrentSong()
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
    if (this.isExist(song)) return
    this.insertSong(song, 0)
    this.setCurrentSongIndex(0)
  }

  public destroy(): void {
    if (this.debounceTimer !== null) {
      clearTimeout(this.debounceTimer)
      this.debounceTimer = null
    }
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

  /**
   * 插入到下一首播放或移动已存在的歌曲到下一首位置
   * @param song 要插入或移动的歌曲
   * @returns 返回是否成功插入或移动
   */
  public insertOrMoveNext(song: TrackAndPrivilege): boolean {
    const targetIndex = this.getCurrentIndex() + 1
    const existingIndex = this.findSongIndexById(song.track.id)

    // 如果歌曲已存在
    if (existingIndex !== -1) {
      // 如果歌曲就在目标位置，不需要移动
      if (existingIndex === targetIndex) {
        return false
      }

      // 如果歌曲在目标位置之后，移动到目标位置
      if (existingIndex > targetIndex) {
        this.moveSong(existingIndex, targetIndex)
      }
      // 如果歌曲在目标位置之前，需要考虑移动后的位置偏移
      else {
        this.moveSong(existingIndex, targetIndex - 1)
      }
    }
    // 如果歌曲不存在，直接插入
    else {
      this.insertSong(song, targetIndex)
    }

    return true
  }
}

const globalPlaylist = GlobalPlaylist.getInstance()
export { globalPlaylist }