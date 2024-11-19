import { StyleConstants } from "../common/Constant"

@Component
export struct ArtistCircleCard {
  @Prop imageUrl: string
  @Prop name: string
  @Prop sizeCard?: string | number = 120

  build() {
    Column({ space: 8 }) {
      // 圆形图片容器
      Stack() {
        // 主图片层
        Image(this.imageUrl)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
      }
      .width(this.sizeCard)
      .aspectRatio(1)
      .clip(true)
      .borderRadius("100%")
      .backgroundColor($r('app.color.artist_card_placeholder'))

      // 艺人名称
      Text(this.name)
        .fontSize(14)
        .fontWeight(StyleConstants.FONT_WEIGHT_SEVEN)
        .fontColor($r('app.color.artist_name'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width(this.sizeCard)
        .textAlign(TextAlign.Center)
    }
    .alignItems(HorizontalAlign.Center)
  }
}