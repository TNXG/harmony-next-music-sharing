import { StyleConstants } from "../common/Constant"

@Component
export struct PersonalFMCard {
  // 预设一些好看的颜色组合
  private readonly colorPairs: Array<[string, string]> = [
    ['rgba(255, 87, 34, 0.8)', 'rgba(233, 30, 99, 0.7)'],     // 暖橙->粉紫
    ['rgba(63, 81, 181, 0.8)', 'rgba(156, 39, 176, 0.7)'],    // 靛蓝->紫色
    ['rgba(0, 150, 136, 0.8)', 'rgba(0, 188, 212, 0.7)'],     // 青绿->蓝绿
    ['rgba(25, 118, 210, 0.8)', 'rgba(21, 101, 192, 0.7)'],   // 深蓝->暗蓝
    ['rgba(76, 175, 80, 0.8)', 'rgba(139, 195, 74, 0.7)'],    // 绿色->浅绿
    ['rgba(171, 71, 188, 0.8)', 'rgba(106, 27, 154, 0.7)'],   // 紫色->深紫
    ['rgba(239, 83, 80, 0.8)', 'rgba(183, 28, 28, 0.7)'],     // 红色->深红
  ]

  // 随机选择一对颜色
  private readonly gradientColors: Array<[ResourceColor, number]> = (() => {
    const randomPair = this.colorPairs[Math.floor(Math.random() * this.colorPairs.length)]
    return [
      [randomPair[0], 0],
      [randomPair[1], 1]
    ]
  })()

  build() {
    Column() {
      Stack({ alignContent: Alignment.Start }) {
        // 渐变背景
        Column()
          .width(StyleConstants.FULL_WIDTH)
          .height(StyleConstants.FULL_HEIGHT)
          .linearGradient({
            angle: 145,
            colors: this.gradientColors,
            repeating: false
          })
          .blur(20)

        // 内容层
        Column() {
          Text('私人FM')
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
    .backdropBlur(12)
  }
}