import { HorizontalScroll } from '../component/HorizontalScroll'
import { SearchBar } from '../component/SearchBar'
import { StyleConstants } from '../common/Constant'
import { PersonalizedPlaylist } from '../type/Personalized'
import { cover, shuffle } from '../common/APIHelper'
import { getPersonalizedCollection } from '../api/Personalized'
import { DailyRecommendCard } from '../component/DailyRecommendCard'
import { PersonalFMCard } from '../component/PersonalFMCard'
import { Artist, Playlist } from '../type/Toplist'
import { ArtistCircleCard } from '../component/ArtistCircleCard'
import { Album } from '../type/Album'
import { promptAction, router } from '@kit.ArkUI'
import { PlaybackControlBar } from '../component/PlaybackControlBar'

@Component
export struct LookUp {
  @StorageLink("PersonalizedPlaylist") personalizedPlaylist: PersonalizedPlaylist[] | undefined = []
  @StorageLink("ToplistArtistList") toplistArtistList: Artist[] | undefined = []
  @StorageLink("NewAlbumList") newAlbumList: Album[] | undefined = []
  @StorageLink("TopListAlbumList") topListAlbumList: Playlist[] | undefined = []
  @State isRefreshing: boolean = false
  @State loadingContent: boolean = true

  aboutToAppear() {
    this.initData()
  }

  waiting() {
    promptAction.showToast({ message: "别催啦，在做啦~" })
  }

  async initData() {
    this.loadingContent = true
    try {
      const result = await getPersonalizedCollection()
      animateTo({
        duration: 400,
        curve: Curve.ExtremeDeceleration
      }, () => {
        this.loadingContent = false
        AppStorage.setOrCreate('PersonalizedPlaylist', result.result)
      })
    } catch (error) {
      console.error('Init data failed:', error)
      this.loadingContent = false
    }
  }

  // async refreshData() {
  //   try {
  //     const result = await getPersonalizedCollection()
  //     AppStorage.setOrCreate('PersonalizedPlaylist', result.result)
  //   } catch (error) {
  //     console.error('Refresh failed:', error)
  //   } finally {
  //     this.isRefreshing = false
  //   }
  // }
  //
  // @Builder
  // Refresh() {
  //   Row() {
  //     Button({ type: ButtonType.Circle }) {
  //       Image($r("app.media.ic_gearshape"))
  //         .width(24)
  //         .height(24)
  //         .backgroundColor($r("app.color.page_background"))
  //     }
  //   }
  // }

  @Builder
  SkeletonLoading() {
    Column() {
      // 推荐歌单骨架
      Row() {
        Row()
          .width('40%')
          .height(24)
          .backgroundColor('#f5f5f5')
          .borderRadius(12)
        Row()
          .width('20%')
          .height(16)
          .backgroundColor('#f5f5f5')
          .borderRadius(8)
      }
      .padding({ left: 16, right: 16 })
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 16 })

      // 推荐歌单列表骨架
      Row() {
        ForEach([1, 2, 3, 4], () => {
          Column() {
            Row()
              .width('40%')
              .aspectRatio(1)
              .backgroundColor('#f5f5f5')
              .borderRadius(16)
              .margin(5)
            Row()
              .width('40%')
              .height(16)
              .backgroundColor('#f5f5f5')
              .borderRadius(8)
              .margin({ top: 8 })
          }
        })
      }
      .padding({ left: 16 })
      .margin({ bottom: 24 })

      // 为你准备骨架
      Row() {
        Row()
          .width('40%')
          .height(24)
          .backgroundColor('#f5f5f5')
          .borderRadius(12)
      }
      .padding({ left: 16, right: 16 })
      .width('100%')
      .margin({ bottom: 16 })

      // 每日推荐和私人FM骨架
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        Row()
          .width('45%')
          .height(120)
          .backgroundColor('#f5f5f5')
          .borderRadius(16)
        Row()
          .width('45%')
          .height(120)
          .backgroundColor('#f5f5f5')
          .borderRadius(16)
      }
      .padding(16)
      .margin({ bottom: 24 })

      // 推荐艺人骨架
      Row() {
        Row()
          .width('40%')
          .height(24)
          .backgroundColor('#f5f5f5')
          .borderRadius(12)
      }
      .padding({ left: 16, right: 16 })
      .width('100%')
      .margin({ bottom: 16 })

      // 推荐艺人列表骨架
      Row() {
        ForEach([1, 2, 3, 4], () => {
          Column() {
            Row()
              .width('30%')
              .aspectRatio(1)
              .backgroundColor('#f5f5f5')
              .borderRadius(100)
              .margin(5)
            Row()
              .width('30%')
              .height(16)
              .backgroundColor('#f5f5f5')
              .borderRadius(8)
              .margin({ top: 8 })
          }
        })
      }
      .padding({ left: 16 })
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
        Text("推荐歌单").font({ size: 24, weight: StyleConstants.FONT_WEIGHT_SEVEN })
        Text("查看更多").font({ size: 14, weight: StyleConstants.FONT_WEIGHT_FOUR }).fontColor(Color.Gray)
          .onClick(() => {
            this.waiting()
          })
      }
      .padding({ left: 16, right: 16 })
      .width(StyleConstants.FULL_WIDTH)
      .justifyContent(FlexAlign.SpaceBetween)

      HorizontalScroll() {
        this.RecommendCollection()
      }

      Row() {
        Text("为你准备").font({ size: 24, weight: StyleConstants.FONT_WEIGHT_SEVEN })
      }
      .padding({ left: 16, right: 16 })
      .width(StyleConstants.FULL_WIDTH)
      .justifyContent(FlexAlign.SpaceBetween)

      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        Column() {
          DailyRecommendCard()
        }.onClick(() => {
          router.pushUrl({
            url: "pages/Daily",
          })
        })

        Column() {
          PersonalFMCard()
        }.onClick(() => {
          router.pushUrl({
            url: "pages/PersonalFm",
          })
        })
      }
      .padding(16)
      .width('100%')

      Row() {
        Text("推荐艺人").font({ size: 24, weight: StyleConstants.FONT_WEIGHT_SEVEN })
      }
      .padding({ left: 16, right: 16 })
      .width(StyleConstants.FULL_WIDTH)
      .justifyContent(FlexAlign.SpaceBetween)

      HorizontalScroll() {
        this.Artist()
      }

      Row() {
        Text("新专速递").font({ size: 24, weight: StyleConstants.FONT_WEIGHT_SEVEN })
        Text("查看更多").font({ size: 14, weight: StyleConstants.FONT_WEIGHT_FOUR }).fontColor(Color.Gray)
          .onClick(() => {
            this.waiting()
          })
      }
      .padding({ left: 16, right: 16 })
      .width(StyleConstants.FULL_WIDTH)
      .justifyContent(FlexAlign.SpaceBetween)

      HorizontalScroll() {
        this.NewAlbum()
      }

      Row() {
        Text("为你打Call").font({ size: 24, weight: StyleConstants.FONT_WEIGHT_SEVEN })
        Text("查看更多").font({ size: 14, weight: StyleConstants.FONT_WEIGHT_FOUR }).fontColor(Color.Gray)
          .onClick(() => {
            this.waiting()
          })
      }
      .padding({ left: 16, right: 16 })
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
            .width("40%")
            .borderRadius(16)
            .aspectRatio(1)
            .objectFit(ImageFit.Cover)
            .margin(5)
          Text(item.name)
            .font({ size: 16, weight: StyleConstants.FONT_WEIGHT_SEVEN })
            .textAlign(TextAlign.Start)
            .width("40%")
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
            .width("40%")
            .borderRadius(16)
            .aspectRatio(1)
            .objectFit(ImageFit.Cover)
            .margin(5)
          Text(item.name)
            .font({ size: 16, weight: StyleConstants.FONT_WEIGHT_SEVEN })
            .textAlign(TextAlign.Start)
            .width("40%")
            .margin({ top: 8 })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(2)
        }.onClick(() => {
          this.waiting()
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
            sizeCard: "30%",
            name: item.name
          })
        }
        .margin(5)
        .onClick(() => {
          this.waiting()
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
            .width("40%")
            .borderRadius(16)
            .aspectRatio(1)
            .objectFit(ImageFit.Cover)
            .margin(5)
          Text(item.name)
            .font({ size: 16, weight: StyleConstants.FONT_WEIGHT_SEVEN })
            .textAlign(TextAlign.Start)
            .width("40%")
            .margin({ top: 8 })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(2)
          Text(item.updateFrequency)
            .font({ size: 12, weight: StyleConstants.FONT_WEIGHT_SEVEN })
            .textAlign(TextAlign.Start)
            .width("40%")
            .fontColor(Color.Gray)
            .margin({ top: 4 })
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

  build() {
    Column() {
      SearchBar({
        // rightSlot: this.Refresh
        onSearch: () => {
          this.waiting()
        }
      })

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
    .width(StyleConstants.FULL_WIDTH)
    .height(StyleConstants.FULL_HEIGHT)
  }
}