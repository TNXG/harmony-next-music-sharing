import { StyleConstants } from "../common/Constant"
import { Artist } from "../type/Toplist"

@Component
export struct SongListCard {
  @Prop title: string
  @Prop tns: string[] | null = null
  @Prop artist: Artist[]
  @Prop index: number = 0
  @Prop coverUrl: string
  @Prop coverSize?: number = 56
  @Prop disabled?: boolean = false
  @Prop active?: boolean = false
  @Prop showIndex: boolean = true
  @BuilderParam rightSlot?: () => void // 添加右侧插槽

  private getTextColor(defaultColor: Resource) {
    if (this.disabled) {
      return $r('app.color.song_number_text_disabled')
    }
    if (this.active) {
      return $r('app.color.song_active_color')
    }
    return defaultColor
  }

  build() {
    Column() {
      Row() {
        if (this.showIndex) {
          // 序号
          Stack({ alignContent: Alignment.Center }) {
            // 毛玻璃背景
            Column()
              .width(36)
              .height(36)
              .borderRadius(8)
              .backdropBlur(16)
              .backgroundColor(!this.active ? $r('app.color.song_number_bg') : 'transparent')

            // 序号文本
            Text((this.index + 1).toString())
              .fontSize(14)
              .fontColor(this.getTextColor($r('app.color.song_number_text_normal')))
              .fontWeight(FontWeight.Medium)
          }
          .width(36)
          .height(36)
          .margin({ right: 16 })
        }

        // 封面图片
        Image(this.coverUrl)
          .width(this.coverSize)
          .height(this.coverSize)
          .borderRadius(8)

        // 标题和创建者信息
        Column() {
          Column() {
            Text() {
              Span(this.title)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.getTextColor($r('app.color.text_primary')))
              if (this.tns) {
                Span(`(${this.tns.join("/")})`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.getTextColor($r('app.color.song_translation')))
              }
            }
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

            Text(this.artist.map(item => item.name).join("/"))
              .fontSize(14)
              .fontColor(this.getTextColor($r('app.color.song_translation')))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .alignSelf(ItemAlign.Start)
          }
          .alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)
        .margin({ left: 12 })
        .alignItems(HorizontalAlign.Start)

        // 右侧插槽
        if (this.rightSlot) {
          Row() {
            this.rightSlot()
          }
          .height('100%')
          .alignItems(VerticalAlign.Center)
          .margin({ left: 12 })
        }
      }
      .width(StyleConstants.FULL_WIDTH)
      .height(this.active ? 80 : 64)
      .padding({ left: 12, right: 16 })
      .opacity(this.disabled ? 0.6 : 1)
      .borderRadius(16)
      .backgroundColor(this.active ? $r('app.color.song_active_bg') : 'transparent')
      .animation({
        duration: 200,
        curve: Curve.EaseOut
      })
    }
    .width(StyleConstants.FULL_WIDTH)
    .padding(this.active ? 8 : 0)
  }
}