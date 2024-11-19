import { StyleConstants } from '../common/Constant'
import pasteboard from '@ohos.pasteboard'
import { promptAction } from '@kit.ArkUI'

@Entry
@Component
struct About {
  @State version: string = '1.0.0'
  @State buildDate: string = '2024-11-16'

  @Builder
  Header() {
    Row() {
      Text('关于')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
    }
    .width(StyleConstants.FULL_WIDTH)
    .height(56)
    .padding({ left: 16, right: 16 })
  }

  @Builder
  AppInfo() {
    Column() {
      // App Icon
      Image($r('app.media.icon'))
        .width(80)
        .height(80)
        .borderRadius(16)
        .margin({ top: 32, bottom: 16 })

      // App Name
      Text($r("app.string.EntryAbility_label"))
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .margin({ bottom: 8 })

      // Version
      Text(`版本 ${this.version}`)
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .margin({ bottom: 4 })

      // Build Date
      Text(`构建于 ${this.buildDate}`)
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .margin({ bottom: 32 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  Disclaimer() {
    Column() {
      Text('免责声明')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .margin({ bottom: 8 })

      Text('此为第三方客户端，不会获取你的任何隐私数据，不存在破解越权行为。')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .textAlign(TextAlign.Center)
        .margin({ left: 32, right: 32 })
        .lineHeight(20)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 24, bottom: 24 })
    .borderRadius(16)
    .backgroundColor($r('app.color.card_background'))
    .margin({ left: 16, right: 16 })
  }

  @Builder
  GitHubLink() {
    Column() {
      Text('开源项目地址')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .margin({ bottom: 4 })

      Text('github.com/Okysu/harmony-next-music-sharing')
        .fontSize(14)
        .fontColor($r('app.color.primary_blue'))
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          pasteboard.createData('text/plain', "https://github.com/Okysu/harmony-next-music-sharing")
          promptAction.showToast({
            message: "已复制到剪切板",
          })
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .margin({ bottom: 32 })
  }

  build() {
    Column() {
      this.Header()
      this.AppInfo()
      this.Disclaimer()

      // Spacer
      Blank()
        .layoutWeight(1)

      this.GitHubLink()
    }
    .width(StyleConstants.FULL_WIDTH)
    .height(StyleConstants.FULL_HEIGHT)
    .backgroundColor($r('app.color.page_background'))
    .expandSafeArea()
  }
}