import { LazyData } from '@pie/lazy-data'

export class DataWindowManager<T> {
  private allData: T[] = [] // 完整数据缓存
  private visibleData: T[] = [] // 当前可见数据
  private startIndex: number = 0
  private readonly windowSize: number
  private readonly bufferSize: number

  constructor(windowSize: number = 60, bufferSize: number = 20) {
    this.windowSize = windowSize
    this.bufferSize = bufferSize
  }

  updateWindow(scrollIndex: number, lazyData: LazyData<T>) {
    const newStartIndex = Math.max(0, scrollIndex - this.bufferSize)
    const endIndex = Math.min(this.allData.length, scrollIndex + this.windowSize + this.bufferSize)

    // 如果窗口位置变化不大，就不更新
    if (Math.abs(newStartIndex - this.startIndex) < this.bufferSize / 2) {
      return
    }

    this.startIndex = newStartIndex
    this.visibleData = this.allData.slice(newStartIndex, endIndex)

    // 更新LazyData
    lazyData.setData(this.visibleData)
    lazyData.notifyDataReload()
  }

  addData(items: T[]) {
    this.allData.push(...items)
  }

  clear() {
    this.allData = []
    this.visibleData = []
    this.startIndex = 0
  }

  getRealIndex(virtualIndex: number): number {
    return this.startIndex + virtualIndex
  }

  getTotalCount(): number {
    return this.allData.length
  }

  getItem(index: number): T | undefined {
    return this.allData[index]
  }

  getAllData(): T[] {
    return this.allData
  }
}