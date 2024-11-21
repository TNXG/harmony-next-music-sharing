import { sample } from "../common/APIHelper"
import Constant, { StyleConstants } from "../common/Constant"

@Component
export struct DailyRecommendCard {
  @State private offsetX: number = 0
  @State private offsetY: number = 0
  private readonly animationDuration: number = 10000

  private readonly randomCover = sample<Resource>(Constant.DEFAULT_COVER)

  private startAnimation() {
    let startTime = Date.now()

    this.timerId = setInterval(() => {
      const elapsed = (Date.now() - startTime) % this.animationDuration
      const progress = elapsed / this.animationDuration

      this.offsetX = 15 * Math.sin(progress * 2 * Math.PI)
      this.offsetY = 10 * Math.cos(progress * 2 * Math.PI)
    }, 16)
  }

  private timerId: number = -1

  aboutToAppear() {
    this.startAnimation()
  }

  aboutToDisappear() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId)
      this.timerId = -1
    }
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Start }) {
        // 背景图层
        Stack() {
          Image(this.randomCover)
            .width("120%")
            .height("120%")
            .objectFit(ImageFit.Cover)
            .translate({ x: this.offsetX, y: this.offsetY })
            .blur(1)
        }
        .width(StyleConstants.FULL_WIDTH)
        .height(StyleConstants.FULL_HEIGHT)

        // 内容层
        Column() {
          Text('今日推荐')
            .fontSize(20)
            .fontWeight(StyleConstants.FONT_WEIGHT_SEVEN)
            .fontColor(Color.White)
            .padding({ left: 12, top: 12 })
        }
        .width(StyleConstants.FULL_WIDTH)
        .alignItems(HorizontalAlign.Start)
      }
      .width(StyleConstants.FULL_WIDTH)
      .height(StyleConstants.FULL_HEIGHT)
    }
    .width("100%")
    .height(100)
    .clip(true)
    .borderRadius(16)
    .backgroundColor('#000')
  }
}