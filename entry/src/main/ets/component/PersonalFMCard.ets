import { StyleConstants } from "../common/Constant"
import { TrackAndPrivilege } from "../type/Playlist"
import { promptAction } from '@kit.ArkUI'
import { globalPlaylist, PlayType } from "../common/GlobalPlayListManager"
import { AccountProfile } from "../type/Account"
import { AnimatedDots } from "./AnimatedDots"
import { EventBus } from "../common/EventBus"

@Component
export struct PersonalFMCard {
  @StorageLink('Track') track: TrackAndPrivilege | undefined = undefined
  @StorageLink("Profile") profile: AccountProfile | null = null
  @State isPlaying: boolean = false

  aboutToAppear() {
    // 检查当前是否在FM模式
    this.isPlaying = false

    EventBus.listen<PlayType>('PlayTypeChange', (type) => {
      if (type == PlayType.PERSONAL_FM) {
        this.isPlaying = true
      } else {
        this.isPlaying = false
      }
    })
  }

  // 预设好看的颜色组合
  private readonly colorPairs: Array<[string, string]> = [
    ['rgba(255, 87, 34, 0.8)', 'rgba(233, 30, 99, 0.7)'],
    ['rgba(63, 81, 181, 0.8)', 'rgba(156, 39, 176, 0.7)'],
    ['rgba(0, 150, 136, 0.8)', 'rgba(0, 188, 212, 0.7)'],
    ['rgba(25, 118, 210, 0.8)', 'rgba(21, 101, 192, 0.7)'],
    ['rgba(76, 175, 80, 0.8)', 'rgba(139, 195, 74, 0.7)'],
    ['rgba(171, 71, 188, 0.8)', 'rgba(106, 27, 154, 0.7)'],
    ['rgba(239, 83, 80, 0.8)', 'rgba(183, 28, 28, 0.7)'],
  ]
  private readonly gradientColors: Array<[ResourceColor, number]> = (() => {
    const randomPair = this.colorPairs[Math.floor(Math.random() * this.colorPairs.length)]
    return [
      [randomPair[0], 0],
      [randomPair[1], 1]
    ]
  })()

  // 处理点击事件
  async handleClick() {
    if (!this.profile) {
      promptAction.showToast({ message: "请先登录" })
      return
    }
    if (this.isPlaying) {
      // 如果正在播放，则停止
      await globalPlaylist.stopPersonalFM()
      this.isPlaying = false
    } else {
      // 如果未播放，则开始
      await globalPlaylist.startPersonalFM()
      this.isPlaying = true
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
        Row() {
          Column() {
            Text('私人FM')
              .fontSize(20)
              .fontWeight(StyleConstants.FONT_WEIGHT_SEVEN)
              .fontColor(Color.White)
              .margin({ bottom: 8 })

            Row() {
              Text(this.isPlaying ? '正在播放' : '点击开启')
                .fontSize(14)
                .fontWeight(StyleConstants.FONT_WEIGHT_FOUR)
                .fontColor('rgba(255, 255, 255, 0.8)')

              if (this.isPlaying) {
                AnimatedDots()
                  .margin({ left: 8 })
              }
            }
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          // 右侧按钮
          Column() {
            Button() {
              Image(this.isPlaying ? $r('app.media.ic_pause_round_triangle_fill') : $r('app.media.ic_play_circle_fill'))
                .width(24)
                .height(24)
                .fillColor(Color.White)
            }
            .width(40)
            .height(40)
            .backgroundColor('rgba(255, 255, 255, 0.2)')
            .borderRadius(20)
          }
          .justifyContent(FlexAlign.Center)
        }
        .width(StyleConstants.FULL_WIDTH)
        .height(StyleConstants.FULL_HEIGHT)
        .padding({
          left: 16,
          right: 16,
          top: 12,
          bottom: 12
        })
        .onClick(() => this.handleClick())
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