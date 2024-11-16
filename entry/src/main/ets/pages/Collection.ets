import { Creator, Privilege, Track, TrackAndPrivilege, TrackId } from "../type/Playlist"
import { cover } from "../common/APIHelper"
import { StyleConstants } from '../common/Constant'
import { SongListCard } from '../component/SongListCard'
import { getPlayListDetail, getPlayListDetailDynamic } from '../api/Playlist'
import { AccountProfile } from '../type/Account'
import { TrackBaseDataSource } from '../viewmodel/TrackDataSource'
import Logger from '../common/Logger'
import { getSongDetail, playlistSubscribe } from '../api/Song'
import { promptAction, router } from '@kit.ArkUI'
import { globalPlaylist } from '../common/GlobalPlayListManager'

interface BasePlayListInfo {
  name: string
  coverImgUrl: string,
  creator: Creator
}

@Entry
@Component
struct Collection {
  @StorageLink("CollectionId") collectionId: string | number | null = null
  @StorageLink("Profile") profile: AccountProfile | null = null
  @StorageLink("Track") track: TrackAndPrivilege | null = null
  @State scrollY: number = 0
  @State appearItems: number[] = []
  @State isLoading: boolean = true
  @State loadingPlaylist: boolean = true
  @State trackIds: TrackId[] = []
  @State basePlayListInfo: BasePlayListInfo | null = null
  @State subscribed: boolean = false
  private dataSource: TrackBaseDataSource = new TrackBaseDataSource()
  private offsetValue = 0
  private isCreator = false
  private allTracks: Track[] = []
  private allPrivileges: Privilege[] = []
  private finished = false;
  private loadAll = false;

  aboutToAppear() {
    if (this.collectionId) {
      this.initData()
    }
  }

  private async loadAllTracks() {
    if (this.finished || !this.profile || this.isCreator) {
      return;
    }

    try {
      // 限制最多加载10000首
      const remainingIds: Array<number | string> = this.trackIds
        .slice(this.offsetValue, 10000)
        .map(t => t.id);

      if (remainingIds.length > 0) {
        const songDetail = await getSongDetail(remainingIds);
        this.allTracks.push(...(songDetail.songs as ESObject as Track[]));
        this.allPrivileges.push(...(songDetail.privileges as ESObject as Privilege[]));
        this.allTracks.forEach((track, index) => {
          globalPlaylist.addSong({
            track: track,
            privilege: this.allPrivileges[index]
          })
        })
        this.finished = true;
      }
    } catch (error) {
      Logger.error('Failed to load all tracks:', error);
    }
  }

  @Builder
  LoadingAnimation() {
    if (this.isLoading) {
      Row() {
        LoadingProgress()
          .width(24)
          .height(24)
          .color('#666')
      }
      .width('100%')
      .height(48)
      .justifyContent(FlexAlign.Center)
      .transition({
        type: TransitionType.All,
        opacity: 0
      })
      .animation({
        duration: 300,
        curve: Curve.EaseOut
      })
    }
  }

  @Builder
  SkeletonLoading() {
    Column() {
      Row() {
        Column()
          .width(120)
          .height(120)
          .borderRadius(12)
          .backgroundColor('#f5f5f5')
          .margin({ right: 16 })

        Column() {
          Row()
            .width('60%')
            .height(24)
            .backgroundColor('#f5f5f5')
            .margin({ bottom: 8 })
          Row()
            .width('40%')
            .height(16)
            .backgroundColor('#f5f5f5')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .height(180)
      .padding(16)

      Column() {
        // 操作栏骨架
        Row() {
          Row()
            .width(100)
            .height(40)
            .backgroundColor('#f5f5f5')
            .borderRadius(20)
          Row()
            .width(100)
            .height(40)
            .backgroundColor('#f5f5f5')
            .borderRadius(20)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ left: 16, right: 16, top: 12 })

        // 列表骨架
        ForEach([1, 2, 3, 4, 5], () => {
          Row() {
            Row()
              .width(40)
              .height(40)
              .backgroundColor('#f5f5f5')
              .borderRadius(4)
              .margin({ right: 12 })
            Column() {
              Row()
                .width('80%')
                .height(16)
                .backgroundColor('#f5f5f5')
                .margin({ bottom: 8 })
              Row()
                .width('50%')
                .height(14)
                .backgroundColor('#f5f5f5')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .padding(16)
          .margin({ bottom: 8 })
        })
      }
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius({ topLeft: 32, topRight: 32 })
    }
    .width('100%')
    .transition({ type: TransitionType.All })
    .animation({
      duration: 300,
      curve: Curve.EaseOut
    })
  }

  async initData() {
    this.loadingPlaylist = true
    this.isLoading = true
    try {
      const playlistDetailRes = await getPlayListDetail(this.collectionId!)
      const playListDetailDynamicRes = await getPlayListDetailDynamic(this.collectionId!)

      this.subscribed = playListDetailDynamicRes.subscribed
      this.trackIds = playlistDetailRes.playlist.trackIds ?? []

      this.allPrivileges = playlistDetailRes.privileges
      this.allTracks = playlistDetailRes.playlist.tracks ?? []

      this.finished = this.allTracks.length == this.trackIds.length

      this.basePlayListInfo = {
        name: playlistDetailRes.playlist.name,
        creator: playlistDetailRes.playlist.creator,
        coverImgUrl: playlistDetailRes.playlist.coverImgUrl
      }

      animateTo({
        duration: 400,
        curve: Curve.ExtremeDeceleration
      }, () => {
        this.loadingPlaylist = false
        this.isCreator = playlistDetailRes.playlist.creator.userId === this.profile?.userId
      })

      if (this.isCreator) {
        this.allTracks.slice(0, 20).forEach((track, index) => {
          animateTo({
            duration: 300,
            curve: Curve.ExtremeDeceleration
          }, () => {
            this.appearItems.push(index)
            this.dataSource.pushTrack(track)
          })
        })
      } else {
        playlistDetailRes.playlist.tracks?.slice(0, 20).forEach((track, index) => {
          animateTo({
            duration: 300,
            curve: Curve.ExtremeDeceleration
          }, () => {
            this.appearItems.push(index)
            this.dataSource.pushTrack(track)
          })
        })
      }
      this.offsetValue = 20
    } catch (error) {
      Logger.error('Failed to init playlist data:', error)
    } finally {
      this.isLoading = false
    }
  }

  async loadMoreTracks() {
    if (!this.collectionId || this.isLoading || this.loadAll) {
      return
    }

    this.isLoading = true
    try {
      if (this.isCreator || this.finished) {
        await new Promise<void>((resolve) => {
          const randomDelay = Math.random() * 1333;
          setTimeout(resolve, randomDelay);
        });

        const tracks = this.isCreator ? this.allTracks : this.allTracks;
        const nextTracks = tracks.slice(this.offsetValue, this.offsetValue + 20)
        nextTracks.forEach((track, index) => {
          const realIndex = this.offsetValue + index
          animateTo({
            duration: 300,
            curve: Curve.ExtremeDeceleration
          }, () => {
            this.appearItems.push(realIndex)
            this.dataSource.pushTrack(track)
          })
        })
        this.offsetValue += nextTracks.length

        // 如果当前数量已经等于总数，那么就不再加载
        if (this.offsetValue >= this.trackIds.length) {
          this.loadAll = true
        }
      } else if (this.profile) {
        const ids: Array<number | string> = (this.trackIds ?? [])
          .slice(this.offsetValue, this.offsetValue + 20)
          .map(t => t.id)

        if (ids.length > 0) {
          const songDetail = await getSongDetail(ids);
          const songs = songDetail.songs;
          // 更新privileges
          this.allPrivileges.push(...(songDetail.privileges as ESObject as Privilege[]));
          songs.forEach((song, index) => {
            const realIndex = this.offsetValue + index
            animateTo({
              duration: 300,
              curve: Curve.ExtremeDeceleration
            }, () => {
              this.appearItems.push(realIndex)
              this.dataSource.pushTrack(song as ESObject as Track)
            })
          })
          this.offsetValue += songs.length
        }

        // 如果当前数量已经等于总数，那么就不再加载
        if (this.offsetValue >= this.trackIds.length) {
          this.loadAll = true
        }
      }
    } catch (error) {
      Logger.error('Track', error)
    } finally {
      this.isLoading = false
    }
  }

  @Builder
  ActionBar() {
    Row() {
      Row() {
        Button({ type: ButtonType.Capsule }) {
          Row() {
            Image($r('app.media.ic_play'))
              .width(20)
              .height(20)
              .fillColor('#666')
              .margin({ right: 8 })
            Text('播放全部')
              .fontColor('#666')
              .fontSize(16)
          }
          .padding({ left: 16, right: 16 })
        }
        .backgroundColor(Color.Transparent)
        .height(40)
        .onClick(async () => {
          // 点击播放全部时，开始加载所有歌曲
          if (!this.isCreator && !this.finished) {
            await this.loadAllTracks();
          }
          // 添加播放列表
          const tempSongs: TrackAndPrivilege[] = []
          this.allTracks.forEach((track, index) => {
            tempSongs.push({
              track: track,
              privilege: this.allPrivileges[index]
            })
          })
          globalPlaylist.overwrite(tempSongs)
          // 加载第一首歌
          const info: TrackAndPrivilege = {
            track: this.allTracks[0],
            privilege: this.allPrivileges[0]
          }
          AppStorage.setOrCreate("Track", info)
          router.pushUrl({
            url: "pages/Playing",
          })
        })
      }

      Button({ type: ButtonType.Capsule }) {
        Row() {
          Image(this.subscribed ? $r("app.media.ic_checkmark") : $r('app.media.ic_plus'))
            .width(20)
            .height(20)
            .fillColor('#666')
            .margin({ right: 8 })
          Text(this.subscribed ? '取消收藏' : '收藏歌单')
            .fontColor('#666')
            .fontSize(16)
        }
        .visibility(this.isCreator ? Visibility.None : Visibility.Visible)
        .padding({ left: 16, right: 16 })
      }
      .backgroundColor(Color.Transparent)
      .height(40)
      .onClick(async ()=>{
        if(!this.isCreator){
          const t = this.subscribed ? 0 : 1
          await playlistSubscribe(this.collectionId!, t)
          this.subscribed = !this.subscribed
        }
      })
    }
    .width(StyleConstants.FULL_WIDTH)
    .padding({ left: 16, right: 16, top: 12 })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  TrackItem(track: Track, index: number) {
    if (this.appearItems.includes(index)) {
      SongListCard({
        title: track.name,
        artist: track.ar,
        coverUrl: cover(track.al.picUrl, 100),
        index,
        tns: track.tns,
        disabled: !this.allPrivileges[index] || this.allPrivileges[index].st < 0,
        active: (!!this.track && this.track.track.id == track.id) ?? false
      })
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
        .onClick(async () => {
          if (this.allPrivileges[index] && this.allPrivileges[index].st >= 0) {
            // 点击列表里面的歌曲时，开始加载所有歌曲
            if (!this.isCreator && !this.finished) {
              await this.loadAllTracks();
            }
            const info: TrackAndPrivilege = {
              track: track,
              privilege: this.allPrivileges[index]
            }
            // 添加播放列表
            const tempSongs: TrackAndPrivilege[] = []
            this.allTracks.forEach((track, index) => {
              tempSongs.push({
                track: track,
                privilege: this.allPrivileges[index]
              })
            })
            globalPlaylist.overwrite(tempSongs)
            globalPlaylist.setCurrentIndex(index)
            AppStorage.setOrCreate("Track", info)
            router.pushUrl({
              url: "pages/Playing",
            })
          } else {
            promptAction.showToast({ message: "灰标歌曲，无法播放" })
          }
        })
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Image(this.basePlayListInfo ? cover(this.basePlayListInfo.coverImgUrl, 512) : '')
        .width(StyleConstants.FULL_WIDTH)
        .height(260)
        .blur(20)
        .opacity(0.6)
        .backgroundColor('#f5f5f5')
        .position({ x: 0, y: 0 })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])

      if (this.loadingPlaylist) {
        this.SkeletonLoading()
      } else {
        Column() {
          Row() {
            Image(this.basePlayListInfo ? cover(this.basePlayListInfo.coverImgUrl, 512) : '')
              .width(120)
              .height(120)
              .borderRadius(12)
              .margin({ right: 16 })
              .shadow({
                radius: 12,
                color: '#00000020',
                offsetX: 0,
                offsetY: 2
              })

            Column() {
              Text(this.basePlayListInfo?.name ?? '')
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Row() {
                Image(this.basePlayListInfo?.creator?.avatarUrl ?? '')
                  .width(24)
                  .height(24)
                  .borderRadius(12)
                  .margin({ right: 8 })
                Text(this.basePlayListInfo?.creator?.nickname ?? '')
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
            if (this.profile === null) {
              Text('登录后查看更多')
                .fontSize(14)
                .fontColor('#999')
                .margin({ bottom: 12 })
            }

            this.ActionBar()

            List({ space: 16 }) {
              ListItem() {
                Grid() {
                  LazyForEach(this.dataSource, (item: Track, index: number) => {
                    GridItem() {
                      this.TrackItem(item, index)
                    }
                  }, (item: Track) => `track-${item.id}`)
                }
                .width(StyleConstants.FULL_WIDTH)
                .columnsTemplate('repeat(1, 1fr)')
                .columnsGap(8)
                .rowsGap(8)
                .padding({ left: 8, right: 8, bottom: 0 })
              }

              ListItem() {
                if (this.profile === null && this.dataSource!.totalCount() > 20) {
                  Text('官方限制未登录只能查看20首')
                    .fontSize(14)
                    .fontColor('#999')
                    .margin({ top: 12, bottom: 12 })
                    .width('100%')
                    .textAlign(TextAlign.Center)
                }

                this.LoadingAnimation()
              }
            }
            .padding({ top: 8 })
            .width(StyleConstants.FULL_WIDTH)
            .layoutWeight(1)
            .edgeEffect(EdgeEffect.Spring)
            .scrollBar(BarState.Off)
            .onReachEnd(() => {
              this.loadMoreTracks()
            })
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          }
          .width(StyleConstants.FULL_WIDTH)
          .layoutWeight(1)
          .backgroundColor(Color.White)
          .borderRadius({ topLeft: 32, topRight: 32 })
          .shadow({
            radius: 24,
            color: '#00000010',
            offsetX: 0,
            offsetY: -2
          })
        }
        .width(StyleConstants.FULL_WIDTH)
        .height(StyleConstants.FULL_HEIGHT)
        .opacity(this.loadingPlaylist ? 0 : 1)
        .transition({ type: TransitionType.All })
        .animation({
          duration: 300,
          curve: Curve.EaseOut
        })
      }
    }
    .width(StyleConstants.FULL_WIDTH)
    .height(StyleConstants.FULL_HEIGHT)
    .backgroundColor(Color.White)
  }
}