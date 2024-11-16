import { TrackAndPrivilege } from "../type/Playlist"

export class PlayListDataSource implements IDataSource {
  private listeners: DataChangeListener[] = []
  protected tracks: TrackAndPrivilege[] = []

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

  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  getData(index: number): TrackAndPrivilege {
    return this.tracks[index]
  }

  totalCount(): number {
    return this.tracks.length
  }

  public pushTrack(track: TrackAndPrivilege): void {
    this.tracks.push(track)
    this.notifyDataAdd(this.tracks.length - 1)
  }

  public refresh(): void {
    this.notifyDataReload()
  }
}