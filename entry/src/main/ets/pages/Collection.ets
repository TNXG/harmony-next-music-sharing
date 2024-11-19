import { Creator, Privilege, Track, TrackAndPrivilege, TrackId, UserPlaylistResponse } from "../type/Playlist"
import { cover } from "../common/APIHelper"
import { StyleConstants } from '../common/Constant'
import { SongListCard } from '../component/SongListCard'
import { getPlayListDetail, getPlayListDetailDynamic } from '../api/Playlist'
import { AccountProfile } from '../type/Account'
import Logger from '../common/Logger'
import { getSongDetail, playlistSubscribe } from '../api/Song'
import { promptAction, router } from '@kit.ArkUI'
import { globalPlaylist } from '../common/GlobalPlayListManager'
import { LazyData } from '@pie/lazy-data'

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
  private dataSource: LazyData<Track> = new LazyData();
  private offsetValue = 0
  private isCreator = false
  private allTracks: Track[] = []
  private allPrivileges: Privilege[] = []
  private finished = false;
  private loadAll = false;
  private privilegeMap = new Map<number | string, Privilege>();

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

        // 更新 privilegeMap
        this.privilegeMap = new Map(
          this.allPrivileges.map(privilege => [privilege.id, privilege])
        );

        // 使用 Map 匹配权限添加歌曲
        this.allTracks.forEach(track => {
          globalPlaylist.addSong({
            track: track,
            privilege: this.privilegeMap.get(track.id)!
          });
        });

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
          .color($r('app.color.text_secondary'))
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
  MoreActions(track: Track) {
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
          const trackAndPrivilege: TrackAndPrivilege = {
            track,
            privilege: this.privilegeMap.get(track.id)!
          }
          globalPlaylist.insertOrMoveNext(trackAndPrivilege)
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

      // 初始化 privilegeMap
      this.privilegeMap = new Map(
        this.allPrivileges.map(privilege => [privilege.id, privilege])
      );

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
            this.dataSource.pushData(track)
          })
        })
      } else {
        playlistDetailRes.playlist.tracks?.slice(0, 20).forEach((track, index) => {
          animateTo({
            duration: 300,
            curve: Curve.ExtremeDeceleration
          }, () => {
            this.appearItems.push(index)
            this.dataSource.pushData(track)
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
            this.dataSource.pushData(track)
          })
        })
        this.offsetValue += nextTracks.length

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
          const privileges = songDetail.privileges as ESObject as Privilege[];

          // 更新 privileges 和 privilegeMap
          this.allPrivileges.push(...privileges);
          privileges.forEach(privilege => {
            this.privilegeMap.set(privilege.id, privilege);
          });

          songs.forEach((song, index) => {
            const realIndex = this.offsetValue + index
            animateTo({
              duration: 300,
              curve: Curve.ExtremeDeceleration
            }, () => {
              this.appearItems.push(realIndex)
              this.dataSource.pushData(song as ESObject as Track)
            })
          })
          this.offsetValue += songs.length
        }

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
        .onClick(async () => {
          if (!this.isCreator && !this.finished) {
            await this.loadAllTracks();
          }

          // 使用 privilegeMap 构建播放列表
          const tempSongs = this.allTracks.map(track => ({
            track,
            privilege: this.privilegeMap.get(track.id)!
          } as TrackAndPrivilege));

          globalPlaylist.overwrite(tempSongs);

          // 加载第一首歌
          const info: TrackAndPrivilege = {
            track: this.allTracks[0],
            privilege: this.privilegeMap.get(this.allTracks[0].id)!
          };

          AppStorage.setOrCreate("Track", info);
          router.pushUrl({
            url: "pages/Playing",
          });
        })
      }

      Button({ type: ButtonType.Capsule }) {
        Row() {
          Image(this.subscribed ? $r("app.media.ic_checkmark") : $r('app.media.ic_plus'))
            .width(20)
            .height(20)
            .fillColor($r('app.color.icon_color'))
            .margin({ right: 8 })
          Text(this.subscribed ? '取消收藏' : '收藏歌单')
            .fontColor($r('app.color.text_secondary'))
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
        disabled: !this.privilegeMap.get(track.id) || this.privilegeMap.get(track.id)!.st < 0,
        active: (!!this.track && this.track.track.id == track.id) ?? false,
        rightSlot:() => {
          this.MoreActions(track)
        }
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
          const privilege = this.privilegeMap.get(track.id);
          if (privilege && privilege.st >= 0) {
            if (!this.isCreator && !this.finished) {
              await this.loadAllTracks();
            }

            const info: TrackAndPrivilege = {
              track: track,
              privilege: privilege
            };

            // 使用 privilegeMap 构建播放列表
            const tempSongs = this.allTracks.map(track => ({
              track,
              privilege: this.privilegeMap.get(track.id)
            } as TrackAndPrivilege));

            globalPlaylist.overwrite(tempSongs);
            globalPlaylist.setCurrentIndex(index);
            AppStorage.setOrCreate("Track", info);
            router.pushUrl({
              url: "pages/Playing",
            });
          } else {
            promptAction.showToast({ message: "灰标歌曲，无法播放" });
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
        .backgroundColor($r('app.color.skeleton_background'))
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
                    .fontColor($r('app.color.text_tertiary'))
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
          .backgroundColor($r('app.color.page_background'))
          .borderRadius({ topLeft: 32, topRight: 32 })
          .shadow({
            radius: 24,
            color: $r('app.color.shadow_light'),
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
    .backgroundColor($r('app.color.page_background'))
    .expandSafeArea()
  }
}