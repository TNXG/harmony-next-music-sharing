import axios, { AxiosResponse } from '@ohos/axios'
import { StyleConstants } from '../common/Constant'

interface HitokotoResponse {
  hitokoto: string
  from: string
  from_who: string
}

@Component
export struct PersonFavorite {
  @Prop count: number | null = null
  @State hitokoto: string = ''
  @State from: string = ''
  private readonly colorPairs: Array<[string, string]> = [
    ['rgba(255, 87, 34, 0.8)', 'rgba(233, 30, 99, 0.7)'], // 暖橙->粉紫
    ['rgba(63, 81, 181, 0.8)', 'rgba(156, 39, 176, 0.7)'], // 靛蓝->紫色
    ['rgba(0, 150, 136, 0.8)', 'rgba(0, 188, 212, 0.7)'], // 青绿->蓝绿
    ['rgba(25, 118, 210, 0.8)', 'rgba(21, 101, 192, 0.7)'], // 深蓝->暗蓝
    ['rgba(76, 175, 80, 0.8)', 'rgba(139, 195, 74, 0.7)'], // 绿色->浅绿
    ['rgba(171, 71, 188, 0.8)', 'rgba(106, 27, 154, 0.7)'], // 紫色->深紫
    ['rgba(239, 83, 80, 0.8)', 'rgba(183, 28, 28, 0.7)'],// 红色->深红
  ]
  private readonly gradientColors: Array<[ResourceColor, number]> = (() => {
    const randomPair = this.colorPairs[Math.floor(Math.random() * this.colorPairs.length)]
    return [
      [randomPair[0], 0],
      [randomPair[1], 1]
    ]
  })()

  // 处理文本换行
  private formatHitokoto(text: string): string {
    const punctuations = ['，', '。', '？', '！', '；', '：']
    let result = text
    punctuations.forEach(punct => {
      result = result.replace(new RegExp(punct, 'g'), punct + '\n')
    })
    return result.trimEnd()
  }

  async aboutToAppear() {
    try {
      const response: AxiosResponse<HitokotoResponse> = await axios.get<HitokotoResponse>('https://v1.hitokoto.cn/?c=j')
      this.hitokoto = this.formatHitokoto(response.data.hitokoto)
      this.from = response.data.from_who !== 'null' ? response.data.from_who : '网易云用户'
    } catch (error) {
      console.error('获取一言失败:', error)
    }
  }

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
          // 标语
          if (this.hitokoto) {
            Column() {
              Text(this.hitokoto)
                .fontSize(12)
                .fontWeight(FontWeight.Normal)
                .fontColor('rgba(255, 255, 255, 0.9)')
                .textAlign(TextAlign.End)
                .padding({ bottom: 4 })

              Text(`—— ${this.from}`)
                .fontSize(10)
                .fontWeight(FontWeight.Normal)
                .fontColor('rgba(255, 255, 255, 0.6)')
                .textAlign(TextAlign.End)
            }
            .width('100%')
            .alignItems(HorizontalAlign.End)
            .padding({ left: 12, right: 12, top: 8 })
          }

          Row() {
            // 标题
            Text('我喜欢的')
              .fontSize(20)
              .fontWeight(StyleConstants.FONT_WEIGHT_SEVEN)
              .fontColor(Color.White)
              .padding(16)

            // 底部统计信息
            if (this.count !== null) {
              Text(`${this.count} 首`)
                .fontSize(14)
                .fontColor('rgba(255, 255, 255, 0.8)')
                .padding(16)
            }
          }
          .width(StyleConstants.FULL_WIDTH)
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width(StyleConstants.FULL_WIDTH)
        .height(StyleConstants.FULL_HEIGHT)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width(StyleConstants.FULL_WIDTH)
      .height(StyleConstants.FULL_HEIGHT)
    }
    .width("90%")
    .height(140)
    .clip(true)
    .borderRadius(16)
    .backdropBlur(12)
    .margin({ top: 16 })
    .justifyContent(FlexAlign.Center)
  }
}