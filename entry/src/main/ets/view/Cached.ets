import { StyleConstants } from '../common/Constant'
import { cacheManager, CacheStats } from '../common/CacheManager'
import { SongCache } from '../type/Song'
import { promptAction } from '@kit.ArkUI'
import Logger from '../common/Logger'
import { qualityDescriptions } from '../common/APIHelper'
import { fileIo as fs } from '@kit.CoreFileKit'

interface CacheValue {
  value: SongCache;
}

interface CacheList {
  key: string;
  data: CacheValue;
}

@Entry
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

  @Builder
  CacheStats() {
    Row() {
      Column() {
        Text(this.stats.count.toString())
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 4 })
        Text('缓存数量')
          .fontSize(14)
          .fontColor('#666')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
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
          .fillColor(Color.White)
      }
    }
    .width(48)
    .height(48)
    .backgroundColor('#FF4040')
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
      ForEach(this.cacheList, (item: CacheList) => {
        ListItem() {
          Row() {
            Image(item.data.value.coverImgUrl)
              .width(56)
              .height(56)
              .borderRadius(8)
              .margin({ right: 12 })

            Column() {
              Text(item.data.value.name)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 4 })

              Text(item.data.value.artist.join(' / '))
                .fontSize(14)
                .fontColor('#666')
                .margin({ bottom: 4 })
                .maxLines(1)

              Row() {
                Text(`音质: ${Object(qualityDescriptions)[item.data.value.level]}`)
                  .fontSize(12)
                  .fontColor('#999')
              }
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .padding(12)
          .backgroundColor(Color.White)
          .borderRadius(12)
        }
        .swipeAction({ end: this.DeleteButton(item) })
        .animation({
          duration: 300,
          curve: Curve.EaseInOut
        })
      })
    }
    .width('100%')
    .layoutWeight(1)
    .listDirection(Axis.Vertical)
  }


  build() {
    Column() {
      Row() {
        Text('本地缓存')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)

        Blank()

        if (this.stats.count > 0) {
          Button({ type: ButtonType.Capsule }) {
            Row() {
              Image($r('app.media.ic_trash'))
                .width(20)
                .height(20)
                .fillColor('#666')
                .margin({ right: 4 })
              Text('清空缓存')
                .fontSize(14)
                .fontColor('#666')
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
            .color('#666')
          Text('加载中...')
            .fontSize(14)
            .fontColor('#666')
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
            .fillColor('#999')
          Text('暂无缓存数据')
            .fontSize(16)
            .fontColor('#666')
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
    .expandSafeArea()
    .padding({ bottom: 16 })
  }
}