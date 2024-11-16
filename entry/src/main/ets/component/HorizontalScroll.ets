import { StyleConstants } from "../common/Constant"

// HorizontalScroll.ets
@Component
export struct HorizontalScroll {
  @BuilderParam content: () => void


  build() {
    Scroll() {
      Row() {
        this.content()
      }
      .padding(16)
      .alignItems(VerticalAlign.Top)
      .justifyContent(FlexAlign.Start)
    }
    .scrollBar(BarState.Off)
    .scrollable(ScrollDirection.Horizontal)
    .width(StyleConstants.FULL_WIDTH)
  }
}