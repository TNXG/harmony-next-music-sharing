import { Track } from "../type/Playlist"

export class TrackBaseDataSource implements IDataSource {
  private listeners: DataChangeListener[] = []
  protected tracks: Track[] = []

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener)
    if (pos >= 0) {
      this.listeners.splice(pos, 1)
    }
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener)
    }
  }

  protected notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index)
    })
  }

  getData(index: number): Track {
    return this.tracks[index]
  }

  totalCount(): number {
    return this.tracks.length
  }

  public pushTrack(track: Track): void {
    this.tracks.push(track)
    this.notifyDataAdd(this.tracks.length - 1)
  }
}