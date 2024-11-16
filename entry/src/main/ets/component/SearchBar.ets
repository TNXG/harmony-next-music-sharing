import { StyleConstants } from "../common/Constant"

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
      // 内容层
      Row({ space: 8 }) {
        Search({
          value: this.searchText,
          placeholder: this.placeholder,
          controller: this.searchController
        })
          .width(this.barWidth)
          .height(40)
          .placeholderColor('#999999')
          .placeholderFont({ size: 16 })
          .textFont({ size: 16 })
          .borderRadius(8)
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