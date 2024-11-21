import { StyleConstants } from "../common/Constant"

@Reusable
@Component
export struct PlaylistCard {
  @Prop count: number
  @Prop coverUrl: string
  @Prop title: string
  @Prop creator: string
  @Prop index: number = 0
  @Prop coverSize?: number = 56
  @BuilderParam rightSlot?: () => void // 添加右侧插槽

  build() {
    Stack() {
      Column() {
        Row() {
          // 序号
          Column() {
            Text((this.index + 1).toString())
              .fontSize(16)
              .fontColor($r('app.color.playlist_index'))
              .width(36)
              .textAlign(TextAlign.Center)
          }
          .height('100%')
          .justifyContent(FlexAlign.Center)

          // 封面图
          Image(this.coverUrl)
            .width(this.coverSize)
            .height(this.coverSize)
            .borderRadius(8)
            .margin({ left: 8 })
            .objectFit(ImageFit.Cover)

          // 标题和创建者信息
          Column() {
            Text(`${this.count}首`)
              .fontSize(12)
              .fontWeight(StyleConstants.FONT_WEIGHT_FIVE)
              .fontColor($r('app.color.playlist_count'))
              .maxLines(1)
              .padding({ right: 12 })
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Text(this.title)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Row() {
              Text(this.creator)
                .fontSize(14)
                .fontColor($r('app.color.playlist_creator'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .margin({ top: 4 })
          }
          .layoutWeight(1)
          .margin({ left: 12 })
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.Center)

          // 右侧插槽
          if (this.rightSlot) {
            Column() {
              this.rightSlot()
            }
            .height('100%')
            .justifyContent(FlexAlign.Center)
          }
        }
        .width('100%')
        .height(80)
        .padding({ left: 12, right: 16 })
        .borderRadius(16)
      }
      .width('100%')
      .backgroundColor(Color.Transparent)
      .borderRadius(16)
      .shadow({
        radius: 20,
        color: $r('app.color.playlist_card_shadow'),
        offsetX: 0,
        offsetY: 2
      })
      .backdropBlur(8)
      .margin({
        left: 16,
        right: 16,
        top: 8,
        bottom: 8
      })
    }
    .width('100%')
    .animation({
      duration: 200,
      curve: Curve.EaseOut
    })
  }
}