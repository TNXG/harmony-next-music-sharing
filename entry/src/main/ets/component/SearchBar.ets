import { StyleConstants } from "../common/Constant"
import { router } from "@kit.ArkUI"

@Component
export struct SearchBar {
  @State searchText: string = ''
  private placeholder?: string = '搜索'
  private searchController: SearchController = new SearchController()
  private onSearch?: (value: string) => void
  @Prop barWidth: string = "60%"
  @BuilderParam rightSlot?: () => void

  build() {
    Stack({ alignContent: Alignment.Start }) {
      Row({ space: 8 }) {
        Search({
          value: this.searchText,
          placeholder: this.placeholder,
          controller: this.searchController
        })
          .width(this.barWidth)
          .height(40)
          .placeholderColor($r('app.color.search_placeholder'))
          .placeholderFont({ size: 16 })
          .textFont({ size: 16 })
          .fontColor($r('app.color.search_text'))
          .backgroundColor($r('app.color.search_background'))
          .borderRadius(8)
          .onClick(() => {
            router.pushUrl({
              url: "pages/CloudSearch"
            })
          })
          .onChange((value: string) => {
            this.searchText = value
          })
          .onSubmit(() => {
            this.onSearch?.(this.searchText)
          })

        if (this.rightSlot) {
          this.rightSlot()
        }
      }
      .expandSafeArea()
      .width(StyleConstants.FULL_WIDTH)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        left: 16,
        right: 16,
        top: 8,
        bottom: 8
      })
    }
    .width(StyleConstants.FULL_WIDTH)
  }
}