import { StyleConstants } from '../common/Constant'
import { cacheManager, CacheStats } from '../common/CacheManager'
import { SongCache } from '../type/Song'
import { promptAction, router } from '@kit.ArkUI'
import Logger from '../common/Logger'
import { cover, qualityDescriptions } from '../common/APIHelper'
import { fileIo as fs } from '@kit.CoreFileKit'
import { audioFileSaver } from '../common/AudioFileSaver'
import { globalPlaylist } from '../common/GlobalPlayListManager'
import { Privilege, TrackAndPrivilege, Track } from '../type/Playlist'
import { Artist } from '../type/Toplist'
import { Album } from '../type/Album'

interface CacheValue {
  value: SongCache;
}

interface CacheList {
  key: string;
  data: CacheValue;
}

interface ReadOptions {
  offset: number;
  length: number;
}

@Component
export struct Cached {
  @StorageLink("CacheList") cacheList: Array<CacheList> = []
  @StorageLink("CacheStats") stats: CacheStats = { count: 0, oldestTime: 0, newestTime: 0 }
  @State isLoading: boolean = false
  @State isDeleting: boolean = false

  private refreshData() {
    try {
      this.isLoading = true
      this.cacheList = cacheManager.getList()
      this.stats = cacheManager.getStats()
    } catch (error) {
      Logger.error('Failed to refresh cache data:', error)
      promptAction.showToast({ message: '加载缓存数据失败' })
    } finally {
      this.isLoading = false
    }
  }

  @Builder
  SwipeActions(item: CacheList) {
    Row() {
      Button() {
        Row() {
          Image($r('app.media.ic_download'))
            .width(24)
            .height(24)
            .fillColor($r('app.color.icon_color'))
        }
      }
      .width(48)
      .height(48)
      .backgroundColor(Color.Transparent)
      .margin({right: 8})
      .onClick(() => {
        this.saveAudio(item)
      })

      this.DeleteButton(item)
    }
  }


  private async saveAudio(item: CacheList) {
    try {
      // 打开源文件
      const srcFile = fs.openSync(item.data.value.path, fs.OpenMode.READ_WRITE)

      // 生成文件名
      const ext = item.data.value.path.split('.').pop() ?? 'mp3'
      const fileName = `${item.data.value.name}-${item.data.value.artist.join(',')}.${ext}`

      // 获取文件信息以确定大小
      const fileStats = fs.statSync(item.data.value.path)
      const fileSize = fileStats.size

      // 创建适当大小的 ArrayBuffer
      let arrayBuffer = new ArrayBuffer(fileSize)
      let readOptions: ReadOptions = {
        offset: 0,
        length: fileSize
      }

      // 读取整个文件内容
      const readLen = fs.readSync(srcFile.fd, arrayBuffer, readOptions)

      // 关闭源文件
      fs.closeSync(srcFile)

      // 保存音频文件
      const result = await audioFileSaver.saveAudioFile({
        fileName: fileName,
        content: arrayBuffer
      })

      if (result.success) {
        promptAction.showToast({ message: '保存成功' })
      }
    } catch (error) {
      Logger.error('Failed to save audio:', error)
      promptAction.showToast({ message: '保存失败' })
    }
  }

  private async clearAllCache() {
    try {
      this.isDeleting = true

      // 1. 先获取所有缓存数据
      const cacheList = cacheManager.getList()
      let hasError = false

      // 2. 遍历删除所有缓存文件
      for (const item of cacheList) {
        const filePath = item.data.value.path
        if (filePath) {
          const deleted = await this.deleteFile(filePath)
          if (!deleted) {
            hasError = true
            Logger.error(`Failed to delete cache file: ${filePath}`)
          }
        }
      }

      // 3. 清除缓存记录
      const result = cacheManager.clear()

      if (result && !hasError) {
        promptAction.showToast({ message: '清除缓存成功' })
      } else if (result && hasError) {
        promptAction.showToast({ message: '部分文件删除失败,请重试' })
      } else {
        promptAction.showToast({ message: '清除缓存失败' })
      }

      // 4. 刷新页面数据
      this.refreshData()
    } catch (error) {
      Logger.error('Failed to clear cache:', error)
      promptAction.showToast({ message: '清除缓存失败' })
    } finally {
      this.isDeleting = false
    }
  }

  private async deleteFile(path: string): Promise<boolean> {
    try {
      await fs.unlink(path)
      return true
    } catch (error) {
      Logger.error(`Failed to delete file ${path}:`, error)
      return false
    }
  }

  private handleTrackClick(item: CacheList, index: number) {
    // 构建播放列表
    const playList:TrackAndPrivilege[] = this.cacheList.map(cacheItem => {
      const track = new Track()
      track.id = Number(cacheItem.data.value.id)
      track.name = cacheItem.data.value.name
      track.ar = cacheItem.data.value.artist.map(artist => {
        const ar = new Artist()
        ar.id = 0
        ar.name = artist
        return ar
      })
      const al = new Album()
      al.id = 0
      al.picUrl = cacheItem.data.value.coverImgUrl
      track.al = al

      const privilege = new Privilege()
      privilege.id = Number(cacheItem.data.value.id)
      privilege.st = 0 // 表示可用状态

      const trackAndPrivilege = new TrackAndPrivilege()
      trackAndPrivilege.track = track
      trackAndPrivilege.privilege = privilege

      return trackAndPrivilege
    })

    // 更新全局播放列表并开始播放
    animateTo({ duration: 0 }, () => {
      globalPlaylist.overwrite(playList, index)
      AppStorage.setOrCreate("Track", playList[index])
    })

    // 跳转到播放页面
    router.pushUrl({ url: "pages/Playing" })
  }

  @Builder
  CacheStats() {
    Row() {
      Column() {
        Text(this.stats.count.toString())
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .margin({ bottom: 4 })
        Text('缓存数量')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.Transparent)
    .borderRadius(16)
    .margin({ top: 16, bottom: 16 })
  }

  @Builder
  DeleteButton(item: CacheList) {
    Button() {
      Row() {
        Image($r('app.media.ic_trash'))
          .width(24)
          .height(24)
          .fillColor($r('app.color.icon_color'))
      }
    }
    .width(48)
    .height(48)
    .backgroundColor(Color.Transparent)
    .margin({right:16})
    .onClick(async () => {
      try {
        // 1. 删除文件
        const deleted = await this.deleteFile(item.data.value.path)
        if (!deleted) {
          promptAction.showToast({ message: '删除文件失败' })
          return
        }

        // 2. 删除缓存记录
        const result = cacheManager.remove(item.key)
        if (result) {
          promptAction.showToast({ message: '删除成功' })
          this.refreshData()
        } else {
          promptAction.showToast({ message: '删除缓存记录失败' })
        }
      } catch (error) {
        Logger.error('Failed to delete cache:', error)
        promptAction.showToast({ message: '删除失败' })
      }
    })
  }

  @Builder
  CacheList() {
    List({ space: 8 }) {
      ForEach(this.cacheList, (item: CacheList, index:number) => {
        ListItem() {
          Row() {
            Image(cover(item.data.value.coverImgUrl, 100))
              .width(56)
              .height(56)
              .borderRadius(8)
              .margin({ right: 12 })

            Column() {
              Text(item.data.value.name)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_primary'))
                .margin({ bottom: 4 })

              Text(item.data.value.artist.join(' / '))
                .fontSize(14)
                .fontColor($r('app.color.text_secondary'))
                .margin({ bottom: 4 })
                .maxLines(1)

              Row() {
                Text(`音质: ${Object(qualityDescriptions)[item.data.value.level]}`)
                  .fontSize(12)
                  .fontColor($r('app.color.text_tertiary'))
              }
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .padding(12)
          .backgroundColor(Color.Transparent)
          .borderRadius(12)
        }
        .onClick(() => {
          this.handleTrackClick(item, index)
        })
        .swipeAction({ end: this.SwipeActions(item) })
        .animation({
          duration: 300,
          curve: Curve.EaseInOut
        })
      })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .listDirection(Axis.Vertical)
  }


  build() {
    Column() {
      Row() {
        Text('本地缓存')
          .fontSize(24)
          .fontColor($r('app.color.text_primary'))

        Blank()

        if (this.stats.count > 0) {
          Button({ type: ButtonType.Capsule }) {
            Row() {
              Image($r('app.media.ic_trash'))
                .width(20)
                .height(20)
                .fillColor($r('app.color.icon_color'))
                .margin({ right: 4 })
              Text('清空缓存')
                .fontSize(14)
                .fontColor($r('app.color.text_secondary'))
            }
            .padding(12)
          }
          .backgroundColor(Color.Transparent)
          .enabled(!this.isDeleting)
          .onClick(() => {
            AlertDialog.show({
              title: '清空缓存',
              message: '确定要清空所有缓存吗？此操作不可恢复。',
              primaryButton: {
                value: '取消',
                action: () => {}
              },
              secondaryButton: {
                value: '确定',
                action: () => {
                  this.clearAllCache()
                }
              }
            })
          })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16 })

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(32)
            .height(32)
            .color($r('app.color.loading_color'))
          Text('加载中...')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.cacheList.length === 0) {
        Column() {
          Image($r('app.media.ic_brush'))
            .width(80)
            .height(80)
            .margin({ bottom: 16 })
            .fillColor($r('app.color.empty_icon_color'))
          Text('暂无缓存数据')
            .fontSize(16)
            .fontColor($r('app.color.text_secondary'))
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        this.CacheStats()
        this.CacheList()
      }
    }
    .width(StyleConstants.FULL_WIDTH)
    .height(StyleConstants.FULL_HEIGHT)
    .backgroundColor($r('app.color.page_background'))
    .expandSafeArea()
    .padding({ bottom: 16 })
  }
}