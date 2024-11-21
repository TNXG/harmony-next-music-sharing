import { Creator, Privilege, Track, TrackAndPrivilege, TrackId, UserPlaylistResponse } from "../type/Playlist"
import { cover } from "../common/APIHelper"
import { StyleConstants } from '../common/Constant'
import { SongListCard } from '../component/SongListCard'
import { getPlayListDetail, getPlayListDetailDynamic } from '../api/Playlist'
import { AccountProfile } from '../type/Account'
import Logger from '../common/Logger'
import { collectSong, getSongDetail, playlistSubscribe } from '../api/Song'
import { promptAction, router } from '@kit.ArkUI'
import { globalPlaylist } from '../common/GlobalPlayListManager'
import { LazyData } from '@pie/lazy-data'
import { PlaylistSelector } from '../component/PlaylistSelector'

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
  @State isLoading: boolean = true
  @State loadingPlaylist: boolean = true
  @State trackIds: TrackId[] = []
  @State basePlayListInfo: BasePlayListInfo | null = null
  @State subscribed: boolean = false
  @State dataSource: LazyData<Track> = new LazyData()
  private offsetValue = 0
  private isCreator = false
  private allTracks: Track[] = []
  private allPrivileges: Privilege[] = []
  private finished = false;
  private privilegeMap = new Map<number | string, Privilege>();
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
    .expandSafeArea()
    .height("100%")
    .backgroundColor($r('app.color.playlist_bg'))
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
        if (this.selectedTracks.size === this.allTracks.length) {
          this.selectedTracks.clear()
        } else {
          this.allTracks.forEach(track => {
            this.selectedTracks.add(track.id)
          })
        }
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
      if (this.isCreator) {
        Button({ type: ButtonType.Capsule }) {
          Row() {
            Image($r('app.media.ic_trash'))
              .width(20)
              .height(20)
              .fillColor($r('app.color.text_primary'))
              .margin({ right: 4 })
            Text('移除')
              .fontSize(14)
              .fontColor($r('app.color.text_primary'))
          }
        }
        .backgroundColor(Color.Transparent)
        .height(40)
        .padding({ left: 16, right: 16 })
        .onClick(async () => {
          AlertDialog.show({
            title: '移除歌曲',
            message: '确定要移除选中的歌曲吗？',
            primaryButton: {
              value: '取消',
              action: () => {
              }
            },
            secondaryButton: {
              value: '确定',
              action: async () => {
                const ids = Array.from(this.selectedTracks)
                await collectSong(this.collectionId, ids, "del")
                this.isSelectMode = false
                this.selectedTracks.clear()
                promptAction.showToast({ message: "已移除歌曲" })
              }
            }
          })
        })
      }

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
        const selectedSongs = this.allTracks
          .filter(track => this.selectedTracks.has(track.id))
          .map(track => {
            const song = new TrackAndPrivilege()
            song.track = track
            song.privilege = this.privilegeMap.get(track.id)!
            return song
          })

        selectedSongs.forEach(song => globalPlaylist.addSong(song))
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
    if (this.collectionId) {
      this.initData()
    }
  }

  private async loadAllTracks() {
    if (this.finished || !this.profile) {
      return;
    }

    try {
      const BATCH_SIZE = 500;
      const MAX_TRACKS = 10000;

      // 获取剩余需要加载的ID
      const remainingIds = this.trackIds
        .slice(this.offsetValue, MAX_TRACKS)
        .map(t => t.id);

      // 分批处理
      for (let i = 0; i < remainingIds.length; i += BATCH_SIZE) {
        const batchIds = remainingIds.slice(i, i + BATCH_SIZE);

        if (batchIds.length === 0) {
          break;
        }

        const songDetail = await getSongDetail(batchIds);

        // 添加到总列表
        this.allTracks.push(...(songDetail.songs as ESObject as Track[]));
        this.allPrivileges.push(...(songDetail.privileges as ESObject as Privilege[]));

        this.dataSource.setData(this.allTracks)
        this.dataSource.notifyDataReload()


        // 更新权限Map
        songDetail.privileges.forEach(privilege => {
          this.privilegeMap.set(privilege.id, new Privilege(privilege as ESObject as Privilege));
        });

        // 处理新加入的歌曲
        songDetail.songs.forEach(track => {
          const song = new TrackAndPrivilege();
          song.track = track as ESObject as Track
          song.privilege = this.privilegeMap.get(track.id)!;
          globalPlaylist.addSong(song);
        });
      }

      this.offsetValue = this.allTracks.length

      this.finished = true;

    } catch (error) {
      Logger.error('Failed to load tracks:', error);
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
          const song = new TrackAndPrivilege()
          song.track = track
          song.privilege = this.privilegeMap.get(track.id)!
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
      {
        value: '从歌单移除歌曲',
        action: () => {
          if (this.isCreator) {
            AlertDialog.show({
              title: '移除歌曲',
              message: '确定要移除这首歌曲吗？',
              primaryButton: {
                value: '取消',
                action: () => {
                }
              },
              secondaryButton: {
                value: '确定',
                action: async () => {
                  await collectSong(this.collectionId, [track.id], "del")
                  promptAction.showToast({ message: "已移除歌曲" })
                }
              }
            })
          } else {
            promptAction.showToast({ message: "嘿！你干嘛，这不是你的歌单！" })
          }
        }
      }
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


      this.dataSource.setData(this.allTracks)
      this.dataSource.notifyDataReload()
      this.offsetValue = this.allTracks.length
    } catch (error) {
      Logger.error('Failed to init playlist data:', error)
    } finally {
      this.isLoading = false
    }
  }

  async loadMoreTracks() {
    if (!this.collectionId || this.isLoading || this.finished) {
      return;
    }

    this.isLoading = true;
    const PAGE_SIZE = 20;

    try {
      // Get next batch of track IDs
      const nextIds = (this.trackIds ?? [])
        .slice(this.offsetValue, this.offsetValue + PAGE_SIZE)
        .map(t => t.id);

      if (nextIds.length === 0) {
        this.finished = true
        return;
      }

      // Fetch track details regardless of creator status
      const songDetail = await getSongDetail(nextIds);
      const songs = songDetail.songs as ESObject as Track[];
      const privileges = songDetail.privileges as ESObject as Privilege[];

      // Update privileges
      this.allPrivileges.push(...privileges);
      privileges.forEach(privilege => {
        this.privilegeMap.set(privilege.id, privilege);
      });

      // Add songs with animation
      songs.forEach((song, index) => {
        animateTo({
          duration: 300,
          curve: Curve.ExtremeDeceleration
        }, () => {
          this.dataSource!.pushData(song);
        });
      });

      // Update offset and check if all loaded
      this.offsetValue += songs.length;
      if (this.offsetValue >= this.trackIds.length) {
        this.finished = true;
      }

    } catch (error) {
      Logger.error('Failed to load more tracks:', error);
    } finally {
      this.isLoading = false;
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
          if (!this.finished) {
            await this.loadAllTracks();
          }

          // 使用 privilegeMap 构建播放列表
          const tempSongs = this.allTracks.map(track => {
            const song = new TrackAndPrivilege()
            song.track = track
            song.privilege = this.privilegeMap.get(track.id)!
            return song
          });

          globalPlaylist.overwrite(tempSongs);

          const song = new TrackAndPrivilege()
          song.track = this.allTracks[0]
          song.privilege = this.privilegeMap.get(this.allTracks[0].id)!

          AppStorage.setOrCreate("Track", song);
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
      .onClick(async () => {
        if (!this.isCreator) {
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
        artist: track.ar,
        coverUrl: cover(track.al.picUrl, 100),
        showIndex: !this.isSelectMode,
        index: this.isSelectMode ? -1 : index,
        tns: track.tns,
        disabled: !this.privilegeMap.get(track.id) || this.privilegeMap.get(track.id)!.st < 0,
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
        .onClick(async () => {
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
          const privilege = this.privilegeMap.get(track.id);
          if (privilege && privilege.st >= 0) {
            if (!this.finished) {
              await this.loadAllTracks();
            }

            const info = new TrackAndPrivilege()
            info.track = track
            info.privilege = privilege

            // 使用 privilegeMap 构建播放列表
            const tempSongs = this.allTracks.map(track => {
              const song = new TrackAndPrivilege()
              song.track = track
              song.privilege = this.privilegeMap.get(track.id)!
              return song
            });

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

  build() {
    Column() {
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
          if (this.isSelectMode) {
            this.SelectModeTopBar()
          }
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
              if (this.dataSource !== null) {
                ListItem() {
                  Grid() {
                    LazyForEach(this.dataSource, (item: Track, index: number) => {
                      GridItem() {
                        this.TrackItem(item, index)
                      }.reuseId("track")
                    }, (item: Track) => `track-${item.id}`)
                  }
                  .width(StyleConstants.FULL_WIDTH)
                  .columnsTemplate('repeat(1, 1fr)')
                  .columnsGap(8)
                  .rowsGap(8)
                  .padding({ left: 8, right: 8, bottom: 0 })
                }
              } else {
                ListItem() {
                  Text("什么都没有")
                }
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
            .cachedCount(3)
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