import { Privilege, Track, TrackAndPrivilege } from "../type/Playlist"
import { cover, isTrackPlayableWithParams } from "../common/APIHelper"
import { StyleConstants } from '../common/Constant'
import { SongListCard } from '../component/SongListCard'
import { AccountProfile } from '../type/Account'
import { promptAction, router } from '@kit.ArkUI'
import { globalPlaylist } from '../common/GlobalPlayListManager'
import { DailySong } from '../type/Song'
import { Artist } from '../type/Toplist'
import { collectSong } from '../api/Song'
import { PlaylistSelector } from '../component/PlaylistSelector'

interface CurrentDate {
  day: number;
  month: number;
}

@Entry
@Component
struct Daily {
  @StorageLink("DailySong") dailySong: DailySong[] | null = null
  @StorageLink("Profile") profile: AccountProfile | null = null
  @StorageLink("Track") track: TrackAndPrivilege | null = null
  @State scrollY: number = 0
  @State appearItems: number[] = []
  @State isLoading: boolean = true
  @State isSelectMode: boolean = false // 是否处于多选模式
  @State selectedTracks: Set<number> = new Set() // 已选择的歌曲id集合
  @State showPlayList: boolean = false;

  @Builder
  PlayList() {
    Column() {
      PlaylistSelector({
        onSelect: async (id: string | number) => {
          const ids = Array.from(this.selectedTracks)
          await collectSong(id, ids)
          promptAction.showToast({ message: "已添加到收藏夹" })
          this.showPlayList = false;
          this.isSelectMode = false
          this.selectedTracks.clear()
        }
      })
    }
    .height("100%")
    .backgroundColor($r('app.color.playlist_bg'))
    .expandSafeArea()
    .layoutWeight(1)
  }

  @Builder
  SelectModeTopBar() {
    Row() {
      Button({ type: ButtonType.Circle }) {
        Image($r('app.media.ic_close'))
          .width(24)
          .height(24)
          .fillColor($r('app.color.icon_color'))
      }
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        this.isSelectMode = false
        this.selectedTracks.clear()
      })

      Text(`已选择 ${this.selectedTracks.size} 首`)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .margin({ left: 12 })

      Blank()

      Button({ type: ButtonType.Circle }) {
        Text('全选')
          .fontColor($r('app.color.text_primary'))
          .fontSize(14)
      }
      .backgroundColor(Color.Transparent)
      .onClick(() => {

      })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.Transparent)
  }

  @Builder
  SelectModeBottomBar() {
    Row({ space: 12 }) {
      Button({ type: ButtonType.Capsule }) {
        Row() {
          Image($r('app.media.ic_star'))
            .width(20)
            .height(20)
            .fillColor($r('app.color.text_primary'))
            .margin({ right: 4 })
          Text('收藏')
            .fontSize(14)
            .fontColor($r('app.color.text_primary'))
        }
      }
      .backgroundColor(Color.Transparent)
      .height(40)
      .padding({ left: 16, right: 16 })
      .margin({ right: 12 })
      .onClick(() => {
        this.showPlayList = true
      })

      Button({ type: ButtonType.Capsule }) {
        Row() {
          Image($r('app.media.ic_plus'))
            .width(20)
            .height(20)
            .fillColor($r('app.color.text_primary'))
            .margin({ right: 4 })
          Text('添加到播放列表')
            .fontSize(14)
            .fontColor($r('app.color.text_primary'))
        }
      }
      .backgroundColor(Color.Transparent)
      .height(40)
      .padding({ left: 16, right: 16 })
      .onClick(() => {
        const selectedSongs = this.dailySong!.filter((_, index) => this.selectedTracks.has(index))
        selectedSongs.forEach(song => {
          const track = new TrackAndPrivilege()
          track.track = song as ESObject as Track
          track.privilege = song.privilege as ESObject as Privilege
          globalPlaylist.insertOrMoveNext(track)
        })
        promptAction.showToast({
          message: `已添加 ${selectedSongs.length} 首歌曲到播放列表`
        })
        this.isSelectMode = false
        this.selectedTracks.clear()
      })
    }
    .padding(8)
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height("100%")
    .backgroundColor($r('app.color.page_background'))
    .position({ x: 0, y: 'calc(100% - 40)' })
    .expandSafeArea()
    .animation({
      duration: 200,
      curve: Curve.EaseInOut
    })
  }

  aboutToAppear() {
    if (!this.profile) {
      promptAction.showToast({ message: "需要登录" })
      router.back()
    }
    // 添加动画效果
    setTimeout(() => {
      this.isLoading = false
      if (this.dailySong) {
        this.dailySong.forEach((_, index) => {
          animateTo({
            duration: 300,
            curve: Curve.ExtremeDeceleration
          }, () => {
            this.appearItems.push(index)
          })
        })
      }
    }, 500)
  }

  @Builder
  MoreActions(track: DailySong) {
    Button({ type: ButtonType.Circle }) {
      Image($r('app.media.ic_more'))
        .width(24)
        .height(24)
        .fillColor($r('app.color.icon_color'))
    }
    .width(36)
    .height(36)
    .backgroundColor(Color.Transparent)
    .bindMenu([
      {
        value: '添加到下一首',
        action: () => {
          const song = new TrackAndPrivilege()
          song.track = track as ESObject as Track
          song.privilege = track.privilege as ESObject as Privilege
          globalPlaylist.insertOrMoveNext(song)
        }
      },
      {
        value: '收藏到歌单',
        action: () => {
          // 弹出收藏歌单选择器
          this.selectedTracks.add(track.id)
          this.showPlayList = true
        }
      },
    ])
  }

  @Builder
  SkeletonLoading() {
    Column() {
      Row() {
        Column()
          .width(120)
          .height(120)
          .borderRadius(12)
          .backgroundColor($r('app.color.skeleton_background'))
          .margin({ right: 16 })

        Column() {
          Row()
            .width('60%')
            .height(24)
            .backgroundColor($r('app.color.skeleton_background'))
            .margin({ bottom: 8 })
          Row()
            .width('40%')
            .height(16)
            .backgroundColor($r('app.color.skeleton_background'))
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .height(180)
      .padding(16)

      Column() {
        Row() {
          Row()
            .width(100)
            .height(40)
            .backgroundColor($r('app.color.skeleton_background'))
            .borderRadius(20)
          Row()
            .width(100)
            .height(40)
            .backgroundColor($r('app.color.skeleton_background'))
            .borderRadius(20)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ left: 16, right: 16, top: 12 })

        ForEach([1, 2, 3, 4, 5], () => {
          Row() {
            Row()
              .width(40)
              .height(40)
              .backgroundColor($r('app.color.skeleton_background'))
              .borderRadius(4)
              .margin({ right: 12 })
            Column() {
              Row()
                .width('80%')
                .height(16)
                .backgroundColor($r('app.color.skeleton_background'))
                .margin({ bottom: 8 })
              Row()
                .width('50%')
                .height(14)
                .backgroundColor($r('app.color.skeleton_background'))
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .padding(16)
          .margin({ bottom: 8 })
        })
      }
      .width('100%')
      .backgroundColor($r('app.color.page_background'))
      .borderRadius({ topLeft: 32, topRight: 32 })
    }
    .width('100%')
    .transition({ type: TransitionType.All })
    .animation({
      duration: 300,
      curve: Curve.EaseOut
    })
  }

  @Builder
  ActionBar() {
    Row() {
      Button({ type: ButtonType.Capsule }) {
        Row() {
          Image($r('app.media.ic_play'))
            .width(20)
            .height(20)
            .fillColor($r('app.color.icon_color'))
            .margin({ right: 8 })
          Text('播放全部')
            .fontColor($r('app.color.text_secondary'))
            .fontSize(16)
        }
        .padding({ left: 16, right: 16 })
      }
      .backgroundColor(Color.Transparent)
      .height(40)
      .onClick(() => {
        if (this.dailySong) {
          const tempSongs: TrackAndPrivilege[] = []
          this.dailySong.forEach((song) => {
            const track = new TrackAndPrivilege()
            track.track = song as ESObject as Track
            track.privilege = song.privilege as ESObject as Privilege
            tempSongs.push(track)
          })
          globalPlaylist.overwrite(tempSongs)
          // 加载第一首歌
          const info = new TrackAndPrivilege()
          info.track = this.dailySong[0] as ESObject as Track
          info.privilege = this.dailySong[0].privilege as ESObject as Privilege
          AppStorage.setOrCreate("Track", info)
          router.pushUrl({
            url: "pages/Playing",
          })
        }
      })
    }
    .width(StyleConstants.FULL_WIDTH)
    .padding({ left: 16, right: 16, top: 12 })
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  TrackItem(track: DailySong, index: number) {
    if (this.appearItems.includes(index)) {
      Row() {
        if (this.isSelectMode) {
          Row() {
            Checkbox()
              .select(this.selectedTracks.has(track.id))
              .onChange((value: boolean) => {
                if (value) {
                  this.selectedTracks.add(track.id)
                } else {
                  this.selectedTracks.delete(track.id)
                }
              })
          }
          .margin({ right: 12 })
        }

        SongListCard({
          title: track.name,
          artist: track.ar as ESObject as Artist[],
          coverUrl: cover(track.al.picUrl, 100),
          index: this.isSelectMode ? -1 : index,
          showIndex: !this.isSelectMode,
          tns: track.tns,
          disabled: !isTrackPlayableWithParams(track as ESObject as Track, track.privilege as ESObject as Privilege).isPlayable,
          active: (!!this.track && this.track.track.id == track.id) ?? false,
          rightSlot: () => {
            if (!this.isSelectMode) {
              this.MoreActions(track)
            }
          }
        })
          .layoutWeight(1)
          .transition({
            type: TransitionType.Insert,
            translate: { x: 0, y: '100%' },
            scale: { x: 0.8, y: 0.8 },
            opacity: 0
          })
          .animation({
            delay: index * 50,
            duration: 400,
            curve: Curve.ExtremeDeceleration
          })
          .onClick(() => {
            if (this.isSelectMode) {
              // 多选模式下点击切换选中状态
              if (this.selectedTracks.has(track.id)) {
                this.selectedTracks.delete(track.id)
              } else {
                this.selectedTracks.add(track.id)
              }
              return
            }

            // 非多选模式下的播放逻辑
            const info = new TrackAndPrivilege()
            info.track = track as ESObject as Track
            info.privilege = track.privilege as ESObject as Privilege

            const playableResult = isTrackPlayableWithParams(info.track, info.privilege)
            if (!playableResult.isPlayable) {
              promptAction.showToast({ message: playableResult.reason })
              return
            }

            // 添加播放列表
            const tempSongs: TrackAndPrivilege[] = []
            this.dailySong?.forEach((song) => {
              const info = new TrackAndPrivilege()
              info.track = song as ESObject as Track
              info.privilege = song.privilege as ESObject as Privilege
              tempSongs.push(info)
            })
            globalPlaylist.overwrite(tempSongs, index)
            AppStorage.setOrCreate("Track", info)
            router.pushUrl({
              url: "pages/Playing",
            })
          })
      }
      .width('100%')
      .gesture(
        LongPressGesture()
          .onAction(() => {
            if (!this.isSelectMode) {
              animateTo({ duration: 200 }, () => {
                this.isSelectMode = true
                this.selectedTracks.add(track.id)
              })
            }
          })
      )
      .padding({ left: 8, right: 8 })
      .borderRadius(8)
      .animation({
        duration: 200,
        curve: Curve.EaseInOut
      })
    }
  }

  private getCurrentDate() {
    const date = new Date()
    return ({
      day: date.getDate(),
      month: date.getMonth() + 1
    } as CurrentDate)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Image(this.profile?.backgroundUrl ?? '')
        .width(StyleConstants.FULL_WIDTH)
        .height(260)
        .blur(20)
        .opacity(0.6)
        .backgroundColor($r('app.color.skeleton_background'))
        .position({ x: 0, y: 0 })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])

      if (this.isLoading) {
        this.SkeletonLoading()
      } else {
        Column() {
          if (this.isSelectMode) {
            this.SelectModeTopBar()
          }
          Row() {
            Column() {
              Text(String(this.getCurrentDate().day))
                .fontSize(40)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 4 })
              Text(String(this.getCurrentDate().month) + '月')
                .fontSize(14)
                .fontColor($r('app.color.text_tertiary'))
            }
            .width(120)
            .height(120)
            .borderRadius(12)
            .margin({ right: 16 })
            .backgroundColor('rgba(255, 255, 255, 0.6)')
            .backdropBlur(16)
            .justifyContent(FlexAlign.Center)
            .shadow({
              radius: 12,
              color: $r('app.color.shadow_color'),
              offsetX: 0,
              offsetY: 2
            })

            Column() {
              Text("今日推荐")
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Row() {
                Image(this.profile?.avatarUrl ?? '')
                  .width(24)
                  .height(24)
                  .borderRadius(12)
                  .margin({ right: 8 })
                Text(this.profile?.nickname ?? '')
                  .fontSize(14)
                  .fontWeight(StyleConstants.FONT_WEIGHT_FIVE)
              }
              .margin({ top: 6 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .height(180)
          .width(StyleConstants.FULL_WIDTH)
          .padding(16)

          Column() {
            this.ActionBar()

            List({ space: 16 }) {
              ListItem() {
                Grid() {
                  ForEach(this.dailySong ?? [], (item: DailySong, index: number) => {
                    GridItem() {
                      this.TrackItem(item, index)
                    }
                  })
                }
                .width(StyleConstants.FULL_WIDTH)
                .columnsTemplate('repeat(1, 1fr)')
                .columnsGap(8)
                .rowsGap(8)
                .padding({ left: 8, right: 8, bottom: 0 })
              }
            }
            .padding({ top: 8 })
            .width(StyleConstants.FULL_WIDTH)
            .layoutWeight(1)
            .edgeEffect(EdgeEffect.Spring)
            .scrollBar(BarState.Off)
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          }
          .width(StyleConstants.FULL_WIDTH)
          .layoutWeight(1)
          .backgroundColor($r('app.color.page_background'))
          .borderRadius({ topLeft: 32, topRight: 32 })
          .shadow({
            radius: 24,
            color: $r('app.color.shadow_light'),
            offsetX: 0,
            offsetY: -2
          })

          if (this.isSelectMode) {
            Column() {
              this.SelectModeBottomBar()
            }
            .width("100%")
            .height(40)
          }
        }
        .width(StyleConstants.FULL_WIDTH)
        .height(StyleConstants.FULL_HEIGHT)
        .opacity(this.isLoading ? 0 : 1)
        .transition({ type: TransitionType.All })
        .animation({
          duration: 300,
          curve: Curve.EaseOut
        })
      }
    }
    .width(StyleConstants.FULL_WIDTH)
    .height(StyleConstants.FULL_HEIGHT)
    .backgroundColor($r('app.color.page_background'))
    .expandSafeArea()
    .bindSheet($$this.showPlayList, this.PlayList(), {
      showClose: false,
      detents: [SheetSize.MEDIUM, SheetSize.LARGE],
      dragBar: false,
      scrollSizeMode: ScrollSizeMode.CONTINUOUS,
      backgroundColor: $r('app.color.playlist_bg'),
      preferType: SheetType.BOTTOM,
    })
  }
}