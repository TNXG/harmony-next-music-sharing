import { HorizontalScroll } from '../component/HorizontalScroll'
import { SearchBar } from '../component/SearchBar'
import { StyleConstants } from '../common/Constant'
import { PersonalizedPlaylist } from '../type/Personalized'
import { cover, shuffle } from '../common/APIHelper'
import { DailyRecommendCard } from '../component/DailyRecommendCard'
import { PersonalFMCard } from '../component/PersonalFMCard'
import { Artist, Playlist } from '../type/Toplist'
import { ArtistCircleCard } from '../component/ArtistCircleCard'
import { Album } from '../type/Album'
import { LengthMetrics, promptAction, router } from '@kit.ArkUI'
import { BreakPointType } from '../common/BreakpointSystem'
import { EventBus } from '../common/EventBus'
import { forceRefreshCache } from '../common/RequestUtil'

@Component
export struct LookUp {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm'
  @StorageLink("PersonalizedPlaylist") personalizedPlaylist: PersonalizedPlaylist[] | undefined = []
  @StorageLink("ToplistArtistList") toplistArtistList: Artist[] | undefined = []
  @StorageLink("NewAlbumList") newAlbumList: Album[] | undefined = []
  @StorageLink("TopListAlbumList") topListAlbumList: Playlist[] | undefined = []
  @State isRefreshing: boolean = false
  @State loadingContent: boolean = true
  // 添加响应式断点配置

  private imageWidth = new BreakPointType({
    sm: '40%',
    md: '30%',
    lg: '20%'
  })
  private artistSize = new BreakPointType({
    sm: '30%',
    md: '25%',
    lg: '15%'
  })
  private titleSize = new BreakPointType({
    sm: 24,
    md: 28,
    lg: 32
  })
  private contentPadding = new BreakPointType({
    sm: 16,
    md: 24,
    lg: 32
  })
  private cardWidth = new BreakPointType({
    sm: '45%',
    md: '45%',
    lg: '30%'
  })

  async aboutToAppear() {
    this.loadingContent = true
    await new Promise<boolean>(resolve => {
      const checkCache = setInterval(() => {
        if (this.personalizedPlaylist && this.toplistArtistList && this.newAlbumList && this.topListAlbumList) {
          // 等页面加载完毕后再显示内容
          setTimeout(() => {
            this.loadingContent = false
            clearInterval(checkCache)
            resolve(true)
          }, 1666)
        }
      }, 100);
    });
  }

  waiting() {
    promptAction.showToast({ message: "别催啦，在做啦~" })
  }

  @Builder
  SkeletonLoading() {
    Column() {
      // 推荐歌单骨架
      Row() {
        Row()
          .width(this.currentBreakpoint === 'lg' ? '30%' : '40%')
          .height(this.titleSize.getValue(this.currentBreakpoint))
          .backgroundColor($r('app.color.skeleton_loading'))
          .borderRadius(12)
        Row()
          .width('20%')
          .height(16)
          .backgroundColor($r('app.color.skeleton_loading'))
          .borderRadius(8)
      }
      .padding({
        left: this.contentPadding.getValue(this.currentBreakpoint),
        right: this.contentPadding.getValue(this.currentBreakpoint)
      })
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 16 })

      // 推荐歌单列表骨架
      Row() {
        ForEach([1, 2, 3, 4], () => {
          Column() {
            Row()
              .width(this.imageWidth.getValue(this.currentBreakpoint))
              .aspectRatio(1)
              .backgroundColor($r('app.color.skeleton_loading'))
              .borderRadius(16)
              .margin(5)
            Row()
              .width(this.imageWidth.getValue(this.currentBreakpoint))
              .height(16)
              .backgroundColor($r('app.color.skeleton_loading'))
              .borderRadius(8)
              .margin({ top: 8 })
          }
        })
      }
      .padding({
        left: this.contentPadding.getValue(this.currentBreakpoint)
      })
      .margin({ bottom: 24 })

      // 为你准备骨架
      Row() {
        Row()
          .width('40%')
          .height(this.titleSize.getValue(this.currentBreakpoint))
          .backgroundColor($r('app.color.skeleton_loading'))
          .borderRadius(12)
      }
      .padding({
        left: this.contentPadding.getValue(this.currentBreakpoint),
        right: this.contentPadding.getValue(this.currentBreakpoint)
      })
      .width('100%')
      .margin({ bottom: 16 })

      // 每日推荐和私人FM骨架
      Flex({ justifyContent: FlexAlign.Start, space: { main: LengthMetrics.px(16) } }) {
        Row()
          .width(this.cardWidth.getValue(this.currentBreakpoint))
          .height(100)
          .backgroundColor($r('app.color.skeleton_loading'))
          .borderRadius(16)
        Row()
          .width(this.cardWidth.getValue(this.currentBreakpoint))
          .height(100)
          .backgroundColor($r('app.color.skeleton_loading'))
          .borderRadius(16)
      }
      .padding(this.contentPadding.getValue(this.currentBreakpoint))
      .margin({ bottom: 24 })

      // 推荐艺人骨架
      Row() {
        Row()
          .width('40%')
          .height(this.titleSize.getValue(this.currentBreakpoint))
          .backgroundColor($r('app.color.skeleton_loading'))
          .borderRadius(12)
      }
      .padding({
        left: this.contentPadding.getValue(this.currentBreakpoint),
        right: this.contentPadding.getValue(this.currentBreakpoint)
      })
      .width('100%')
      .margin({ bottom: 16 })

      // 推荐艺人列表骨架
      Row() {
        ForEach([1, 2, 3, 4], () => {
          Column() {
            Row()
              .width(this.artistSize.getValue(this.currentBreakpoint))
              .aspectRatio(1)
              .backgroundColor($r('app.color.skeleton_loading'))
              .borderRadius(100)
              .margin(5)
            Row()
              .width(this.artistSize.getValue(this.currentBreakpoint))
              .height(16)
              .backgroundColor($r('app.color.skeleton_loading'))
              .borderRadius(8)
              .margin({ top: 8 })
          }
        })
      }
      .padding({
        left: this.contentPadding.getValue(this.currentBreakpoint)
      })
    }
    .width('100%')
    .transition({ type: TransitionType.All })
    .animation({
      duration: 300,
      curve: Curve.EaseOut
    })
  }

  @Builder
  MainContent() {
    Column() {
      Row() {
        Text("推荐歌单")
          .font({
            size: this.titleSize.getValue(this.currentBreakpoint),
            weight: StyleConstants.FONT_WEIGHT_SEVEN
          })
          .fontColor($r('app.color.title_text'))
        // Text("查看更多")
        //   .font({ size: 14, weight: StyleConstants.FONT_WEIGHT_FOUR })
        //   .fontColor($r('app.color.more_text'))
        //   .onClick(() => {
        //     this.waiting()
        //   })
      }
      .padding({
        left: this.contentPadding.getValue(this.currentBreakpoint),
        right: this.contentPadding.getValue(this.currentBreakpoint)
      })
      .width(StyleConstants.FULL_WIDTH)
      .justifyContent(FlexAlign.SpaceBetween)

      HorizontalScroll() {
        this.RecommendCollection()
      }


      Row() {
        Text("为你准备")
          .font({
            size: this.titleSize.getValue(this.currentBreakpoint),
            weight: StyleConstants.FONT_WEIGHT_SEVEN
          })
          .fontColor($r('app.color.title_text'))
      }
      .padding({
        left: this.contentPadding.getValue(this.currentBreakpoint),
        right: this.contentPadding.getValue(this.currentBreakpoint)
      })
      .width(StyleConstants.FULL_WIDTH)
      .justifyContent(FlexAlign.SpaceBetween)

      Flex({ justifyContent: FlexAlign.Start, space: { main: LengthMetrics.px(16) } }) {
        Column() {
          DailyRecommendCard()
        }
        .width(this.cardWidth.getValue(this.currentBreakpoint))
        .onClick(() => {
          router.pushUrl({
            url: "pages/Daily",
          })
        })

        Column() {
          PersonalFMCard()
        }
        .width(this.cardWidth.getValue(this.currentBreakpoint))
      }
      .padding(this.contentPadding.getValue(this.currentBreakpoint))
      .width('100%')

      Row() {
        Text("推荐艺人")
          .font({
            size: this.titleSize.getValue(this.currentBreakpoint),
            weight: StyleConstants.FONT_WEIGHT_SEVEN
          })
          .fontColor($r('app.color.title_text'))
      }
      .padding({
        left: this.contentPadding.getValue(this.currentBreakpoint),
        right: this.contentPadding.getValue(this.currentBreakpoint)
      })
      .width(StyleConstants.FULL_WIDTH)
      .justifyContent(FlexAlign.SpaceBetween)

      HorizontalScroll() {
        this.Artist()
      }

      Row() {
        Text("新专速递")
          .font({
            size: this.titleSize.getValue(this.currentBreakpoint),
            weight: StyleConstants.FONT_WEIGHT_SEVEN
          })
          .fontColor($r('app.color.title_text'))
        // Text("查看更多")
        //   .font({ size: 14, weight: StyleConstants.FONT_WEIGHT_FOUR })
        //   .fontColor($r('app.color.more_text'))
        //   .onClick(() => {
        //     this.waiting()
        //   })
      }
      .padding({
        left: this.contentPadding.getValue(this.currentBreakpoint),
        right: this.contentPadding.getValue(this.currentBreakpoint)
      })
      .width(StyleConstants.FULL_WIDTH)
      .justifyContent(FlexAlign.SpaceBetween)

      HorizontalScroll() {
        this.NewAlbum()
      }

      Row() {
        Text("为你打Call")
          .font({
            size: this.titleSize.getValue(this.currentBreakpoint),
            weight: StyleConstants.FONT_WEIGHT_SEVEN
          })
          .fontColor($r('app.color.title_text'))
        // Text("查看更多")
        //   .font({ size: 14, weight: StyleConstants.FONT_WEIGHT_FOUR })
        //   .fontColor($r('app.color.more_text'))
        //   .onClick(() => {
        //     this.waiting()
        //   })
      }
      .padding({
        left: this.contentPadding.getValue(this.currentBreakpoint),
        right: this.contentPadding.getValue(this.currentBreakpoint)
      })
      .width(StyleConstants.FULL_WIDTH)
      .justifyContent(FlexAlign.SpaceBetween)

      HorizontalScroll() {
        this.TopCollection()
      }
    }
    .width(StyleConstants.FULL_WIDTH)
    .opacity(this.loadingContent ? 0 : 1)
    .transition({ type: TransitionType.All })
    .animation({
      duration: 300,
      curve: Curve.EaseOut
    })
  }

  @Builder
  RecommendCollection() {
    if (this.personalizedPlaylist) {
      ForEach(this.personalizedPlaylist, (item: PersonalizedPlaylist) => {
        Column() {
          Image(cover(item.picUrl, 256))
            .alt(item.copywriter)
            .width(this.imageWidth.getValue(this.currentBreakpoint))
            .borderRadius(16)
            .aspectRatio(1)
            .objectFit(ImageFit.Cover)
            .margin(5)
          Text(item.name)
            .font({ size: 16, weight: StyleConstants.FONT_WEIGHT_SEVEN })
            .textAlign(TextAlign.Start)
            .width(this.imageWidth.getValue(this.currentBreakpoint))
            .margin({ top: 8 })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(2)
        }
        .onClick(() => {
          AppStorage.setOrCreate("CollectionId", item.id)
          router.pushUrl({
            url: "pages/Collection",
          })
        })
      })
    }
  }

  @Builder
  NewAlbum() {
    if (this.newAlbumList) {
      ForEach(this.newAlbumList, (item: Album) => {
        Column() {
          Image(cover(item.picUrl, 256))
            .alt(item.name)
            .width(this.imageWidth.getValue(this.currentBreakpoint))
            .borderRadius(16)
            .aspectRatio(1)
            .objectFit(ImageFit.Cover)
            .margin(5)
          Text(item.name)
            .font({ size: 16, weight: StyleConstants.FONT_WEIGHT_SEVEN })
            .textAlign(TextAlign.Start)
            .width(this.imageWidth.getValue(this.currentBreakpoint))
            .margin({ top: 8 })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(2)
        }.onClick(() => {
          router.pushUrl({
            url: "pages/CloudSearch",
            params: {
              keywords: item.name
            }
          })
        })
      })
    }
  }

  @Builder
  Artist() {
    if (this.toplistArtistList) {
      ForEach(shuffle<Artist>(this.toplistArtistList, 10), (item: Artist) => {
        Column() {
          ArtistCircleCard({
            imageUrl: cover(item.picUrl, 512),
            sizeCard: this.artistSize.getValue(this.currentBreakpoint),
            name: item.name
          })
        }
        .margin(5)
        .onClick(() => {
          router.pushUrl({
            url: "pages/CloudSearch",
            params: {
              keywords: item.name
            }
          })
        })
      })
    }
  }

  @Builder
  TopCollection() {
    if (this.topListAlbumList) {
      ForEach(this.topListAlbumList.slice(0, 10), (item: Playlist) => {
        Column() {
          Image(cover(item.coverImgUrl, 256))
            .alt(item.name)
            .width(this.imageWidth.getValue(this.currentBreakpoint))
            .borderRadius(16)
            .aspectRatio(1)
            .objectFit(ImageFit.Cover)
            .margin(5)
          Text(item.name)
            .font({ size: 16, weight: StyleConstants.FONT_WEIGHT_SEVEN })
            .textAlign(TextAlign.Start)
            .width(this.imageWidth.getValue(this.currentBreakpoint))
            .margin({ top: 8 })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(2)
          Text(item.updateFrequency)
            .font({ size: 12, weight: StyleConstants.FONT_WEIGHT_SEVEN })
            .textAlign(TextAlign.Start)
            .width(this.imageWidth.getValue(this.currentBreakpoint))
            .fontColor(Color.Gray)
            .margin({ top: 4 })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(2)
        }
        .onClick(() => {
          forceRefreshCache()
          AppStorage.setOrCreate("CollectionId", item.id)
          router.pushUrl({
            url: "pages/Collection",
          })
        })
      })
    }
  }

  build() {
    Column() {
      SearchBar({})

      Refresh({ refreshing: $$this.isRefreshing, offset: 120, friction: 100 }) {
        List() {
          ListItem() {
            if (this.loadingContent) {
              this.SkeletonLoading()
            } else {
              this.MainContent()
            }
          }
        }
        .scrollBar(BarState.Off)
        .width(StyleConstants.FULL_WIDTH)
        .edgeEffect(EdgeEffect.Spring)
        .layoutWeight(1)
      }
      .onRefreshing(async () => {
        this.isRefreshing = true
        forceRefreshCache()
        EventBus.send("ViewChange", "lookup")
        this.isRefreshing = false
      })
      .margin({ bottom: 72 })
    }
    .width(StyleConstants.FULL_WIDTH)
    .height(StyleConstants.FULL_HEIGHT)
    .backgroundColor($r('app.color.page_background'))
  }
}