import { BreakpointSystem } from '../common/BreakpointSystem';
import { BreakpointConstants, StyleConstants, PageConstants, } from '../common/Constant'; // 通用工具
import { EventBus } from '../common/EventBus';
import { PlaybackControlBar } from '../component/PlaybackControlBar';
import { TrackAndPrivilege } from '../type/Playlist';
import { Cached } from '../view/Cached';
import { Library } from '../view/Library';
import { LookUp } from '../view/LookUp';
import { buttonInfo, ButtonInfoModel } from '../viewmodel/BottomButtonData'; // 底部导航数据


@Entry
@Component
struct Index {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm';
  @State currentPageIndex: number = 0;
  @StorageLink("Track") track: TrackAndPrivilege | null = null
  private breakpointSystem = new BreakpointSystem();
  private controller: TabsController = new TabsController()

  async aboutToAppear() {
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
        .fillColor(this.currentPageIndex === button.index ?
        $r('app.color.tab_icon_active') :
        $r('app.color.tab_icon_inactive'))
      Text(button.title)
        .fontColor(this.currentPageIndex === button.index ?
        $r('app.color.tab_text_active') :
        $r('app.color.tab_text_inactive'))
        .opacity(this.currentPageIndex === button.index ?
        StyleConstants.FULL_OPACITY :
        StyleConstants.SIXTY_OPACITY)
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
          Column() {
            Scroll() {
              LookUp()
            }
            .width('100%')
            .layoutWeight(1)

            PlaybackControlBar()
          }
          .width('100%')
          .height('100%')
        }
        .tabBar(this.BottomNavigation(buttonInfo[0]))

        TabContent() {
          Column() {
            Scroll() {
              Library()
            }
            .width('100%')
            .layoutWeight(1)

            PlaybackControlBar()
          }
          .width('100%')
          .height('100%')
        }
        .tabBar(this.BottomNavigation(buttonInfo[1]))

        TabContent() {
          Column() {
            Scroll() {
              Cached()
            }
            .width('100%')
            .layoutWeight(1)

            PlaybackControlBar()
          }
          .width('100%')
          .height('100%')
        }
        .tabBar(this.BottomNavigation(buttonInfo[2]))
      }
      .barWidth(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ?
      $r('app.float.bar_width') : StyleConstants.FULL_WIDTH)
      .barHeight(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ?
      StyleConstants.SIXTY_HEIGHT : $r('app.float.vp_fifty_six'))
      .vertical(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG)
      .scrollable(false)
      .clip(false)
      .layoutWeight(1)
      .expandSafeArea()
      .onChange(async (index: number) => {
        this.currentPageIndex = index;
        EventBus.send("ViewChange", index == 0 ? "lookup" : index == 1 ? "library" : "cached")
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .expandSafeArea()
  }
}