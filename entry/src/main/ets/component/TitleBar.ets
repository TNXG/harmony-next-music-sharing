import { StyleConstants } from "../common/Constant"

// TitleBar.ets
@Component
export struct TitleBar {
  @Prop title: string
  @BuilderParam rightSlot?: () => void // 右侧插槽，可选

  build() {
    Row({ space: 8 }) {
      Row() {
        Text(this.title).font({ size: 24, weight: StyleConstants.FONT_WEIGHT_SEVEN })
      }
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)

      // 如果有传入rightSlot则使用rightSlot
      if (this.rightSlot) {
        Row() {
          this.rightSlot
        }.padding({ left: 16, right: 16 })
      }
    }
    .width(StyleConstants.FULL_WIDTH)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      left: 16,
      right: 16,
      top: 8,
      bottom: 8
    })
  }
}