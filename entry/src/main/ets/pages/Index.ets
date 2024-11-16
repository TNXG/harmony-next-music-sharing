import { BreakpointSystem } from '../common/BreakpointSystem';
import { BreakpointConstants, StyleConstants, PageConstants, } from '../common/Constant'; // 通用工具
import { EventBus } from '../common/EventBus';
import { Cached } from '../view/Cached';
import { Library } from '../view/Library';
import { LookUp } from '../view/LookUp';
import { buttonInfo, ButtonInfoModel } from '../viewmodel/BottomButtonData'; // 底部导航数据


@Entry
@Component
struct Index {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm';
  @State currentPageIndex: number = 0;
  private breakpointSystem = new BreakpointSystem();
  private controller: TabsController = new TabsController()

  async aboutToAppear() {
    // await this.controller.preloadItems([0, 1, 2])
    this.breakpointSystem.register();
  }

  aboutToDisappear() {
    this.breakpointSystem.unregister();
  }

  @Builder
  BottomNavigation(button: ButtonInfoModel) {
    Column({ space: PageConstants.BUTTON_SPACE }) {
      Image(this.currentPageIndex === button.index ? button.selectImg : button.img)
        .objectFit(ImageFit.Contain)
        .width($r('app.float.main_image_size'))
        .height($r('app.float.main_image_size'))
      Text(button.title)
        .fontColor(this.currentPageIndex === button.index ? $r('app.color.focus_color') :
        $r('app.color.un_focus_color'))
        .opacity(this.currentPageIndex === button.index ? StyleConstants.FULL_OPACITY : StyleConstants.SIXTY_OPACITY)
        .fontWeight(StyleConstants.FONT_WEIGHT_FIVE)
        .textAlign(TextAlign.Center)
        .fontSize($r('app.float.micro_font_size'))
    }
    .width(StyleConstants.FULL_WIDTH)
    .height(StyleConstants.FULL_HEIGHT)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Column() {
      Tabs({
        barPosition: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ?
        BarPosition.Start : BarPosition.End,
        index: this.currentPageIndex,
        controller: this.controller
      }) {
        TabContent() {
          LookUp()
        }
        .tabBar(this.BottomNavigation(buttonInfo[0]))
        .expandSafeArea()

        TabContent() {
          Library()
        }
        .tabBar(this.BottomNavigation(buttonInfo[1]))
        .expandSafeArea()

        TabContent() {
          Cached()
        }
        .tabBar(this.BottomNavigation(buttonInfo[2]))
        .expandSafeArea()
      }
      .barWidth(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ?
      $r('app.float.bar_width') : StyleConstants.FULL_WIDTH)
      .barHeight(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ?
      StyleConstants.SIXTY_HEIGHT : $r('app.float.vp_fifty_six'))
      .vertical(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG)
      .scrollable(false)
      .clip(false)
      .onChange(async (index: number) => {
        this.currentPageIndex = index;
        EventBus.send("ViewChange", index == 0 ? "lookup" : index == 1 ? "library" : "cached")
      })
    }
    .backgroundColor($r('app.color.page_background'))
    .expandSafeArea()
  }
}
