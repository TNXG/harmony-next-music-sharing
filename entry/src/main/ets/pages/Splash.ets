import { router } from '@kit.ArkUI'

@Entry
@Component
struct Splash {
  @State private textOpacity: number = 0
  @State private buttonOpacity: number = 0
  @State private contentTranslateY: number = 0 // 用于控制内容向下移动
  @State private iconOpacity: number = 0

  aboutToAppear() {
    // 第一阶段：显示文字
    setTimeout(() => {
      animateTo({
        duration: 2000,
        curve: Curve.EaseInOut
      }, () => {
        this.textOpacity = 1
      })
    }, 500)

    // 第二阶段：内容下移并显示图标和按钮
    setTimeout(() => {
      animateTo({
        duration: 800,
        curve: Curve.EaseInOut
      }, () => {
        this.contentTranslateY = 0 // 向下移动的距离
      })

      // 图标和按钮一起渐显
      animateTo({
        duration: 1000,
        curve: Curve.EaseInOut
      }, () => {
        this.iconOpacity = 1
        this.buttonOpacity = 1
      })
    }, 2500)
  }

  build() {
    Column() {
      // 应用图标
      Image($r('app.media.icon'))
        .width(120)
        .height(120)
        .opacity(this.iconOpacity)
        .margin({ bottom: 48 })
        .borderRadius(20)
        .transition({
          type: TransitionType.All,
          opacity: this.iconOpacity
        })
        .animation({
          duration: 1000,
          curve: Curve.EaseInOut
        })

      Column() {
        // 文字部分
        Text('献给那些知道我名字的人')
          .fontSize(22)
          .fontWeight(FontWeight.Normal)
          .fontColor('#333333')
          .margin({ bottom: 48 })
          .opacity(this.textOpacity)
          .transition({
            type: TransitionType.All,
            opacity: this.textOpacity
          })
          .animation({
            duration: 2000,
            curve: Curve.EaseInOut
          })

        // 按钮部分
        Button('立即使用', { type: ButtonType.Capsule })
          .width(240)
          .height(48)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#333333')
          .opacity(this.buttonOpacity)
          .transition({
            type: TransitionType.All,
            opacity: this.buttonOpacity
          })
          .animation({
            duration: 1000,
            curve: Curve.EaseInOut
          })
          .onClick(() => {
            router.pushUrl({ url: 'pages/Index' })
          })
      }
      .translate({ y: this.contentTranslateY })
      .transition({
        type: TransitionType.All,
        translate: { y: this.contentTranslateY }
      })
      .animation({
        duration: 800,
        curve: Curve.EaseInOut
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}