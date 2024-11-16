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
              .backgroundColor(!this.active ? 'rgba(245, 245, 245, 0.6)' : 'transparent')

            // 序号文本
            Text((this.index + 1).toString())
              .fontSize(14)
              .fontColor(this.disabled ? '#CCCCCC' : (this.active ? '#3478F6' : '#999999'))
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
                .fontColor(this.disabled ? '#CCCCCC' : (this.active ? '#3478F6' : '#000000'))
              if (this.tns) {
                Span(`(${this.tns.join("/")})`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.disabled ? '#CCCCCC' : (this.active ? '#3478F6' : '#86868b'))
              }
            }
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

            Text(this.artist.map(item => item.name).join("/"))
              .fontSize(14)
              .fontColor(this.disabled ? '#CCCCCC' : (this.active ? '#3478F6' : '#86868b'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .alignSelf(ItemAlign.Start)
          }
          .alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)
        .margin({ left: 12 })
        .alignItems(HorizontalAlign.Start)
      }
      .width(StyleConstants.FULL_WIDTH)
      .height(this.active ? 80 : 64)
      .padding({ left: 12, right: 16 })
      .opacity(this.disabled ? 0.6 : 1)
      .borderRadius(16)
      .backgroundColor(this.active ? 'rgba(52, 120, 246, 0.1)' : 'transparent')
      .animation({
        duration: 200,
        curve: Curve.EaseOut
      })
    }
    .width(StyleConstants.FULL_WIDTH)
    .padding(this.active ? 8 : 0)
  }
}