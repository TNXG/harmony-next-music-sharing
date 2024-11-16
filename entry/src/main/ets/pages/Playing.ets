import { BreakPointType } from "../common/BreakpointSystem"
import { BreakpointConstants, StyleConstants } from "../common/Constant"
import { TrackAndPrivilege } from '../type/Playlist'
import { globalPlaylist, PlaylistChangeType, PlayMode } from '../common/GlobalPlayListManager'
import { cover } from '../common/APIHelper'
import { avPlayerManager } from '../common/AVPlayerManager'
import { EventBus } from '../common/EventBus'
import { PlayListDataSource } from '../viewmodel/PlayListDataSource'

import { PlayList } from '../component/PlayList'

@Entry
@Component
struct Playing {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm'
  @State currentTime: number = 0
  @State duration: number = 0
  @State isProgressBarExpanded: boolean = false
  @State selectedTabIndex: number = 0
  @State isFavorite: boolean = false
  @State isPlaying: boolean = false
  @State playMode: PlayMode = globalPlaylist.getPlayMode()
  @State showPlaylist: boolean = false
  @StorageLink("Track") track: TrackAndPrivilege | null = null
  private updateTimer: number = -1
  private playerManager = avPlayerManager
  private dataSource: PlayListDataSource = new PlayListDataSource()
  @State appearItems: number[] = []
  @State isLoading: boolean = false
  @State loadAll: boolean = false

  @Builder
  PlayListBuilder() {
    Column() {
      PlayList({ showPlaylist: $showPlaylist })
    }
    .height("100%")
    .layoutWeight(1)
  }

  async aboutToAppear() {
    // Initialize current time and duration
    const player = await this.playerManager.getAVPlayerInstance()
    this.currentTime = player.currentTime
    this.duration = player.duration
    this.isPlaying = player.state === 'playing'

    // Setup player state listeners
    this.playerManager.addListener('onPlay', () => {
      this.isPlaying = true
    })

    this.playerManager.addListener('onPause', () => {
      this.isPlaying = false
    })

    this.playerManager.addListener('onStop', () => {
      this.isPlaying = false
    })

    this.playerManager.addListener('onStateChange', (state: string) => {
      if (state === 'playing') {
        this.isPlaying = true
      } else if (state === 'paused' || state === 'stopped') {
        this.isPlaying = false
      }
    })

    // Start position update timer
    this.updateTimer = setInterval(async () => {
      const player = await this.playerManager.getAVPlayerInstance()
      this.currentTime = player.currentTime
      this.duration = player.duration
    }, 500)

    EventBus.listen<PlayMode>('PlayModeSet', () => {
      this.playMode = globalPlaylist.playMode
    })

    EventBus.listen<number>('TrackLike', (like) => {
      this.isFavorite = like == 1
    })
  }

  aboutToDisappear() {
    if (this.updateTimer !== -1) {
      clearInterval(this.updateTimer)
      this.updateTimer = -1
    }
    this.playerManager.clearCallbacks()
  }

  formatTime(milliseconds: number): string {
    if (isNaN(milliseconds) || milliseconds < 0) {
      return '0:00'
    }
    const seconds = Math.floor(milliseconds / 1000)
    const mins = Math.floor(seconds / 60)
    const secs = Math.floor(seconds % 60)
    return `${mins}:${secs.toString().padStart(2, '0')}`
  }

  getFontSize(text: string, baseSize = 18, maxLength = 36): number {
    if (!text) {
      return baseSize
    }
    if (text.length <= maxLength) {
      return baseSize
    }
    return Math.max(12, baseSize * maxLength / text.length)
  }

  @Builder
  BlurBackground() {
    Stack() {
      Image(cover(this.track?.track.al.picUrl ?? "", 512))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .blur(98)
        .opacity(0.6)
        .expandSafeArea()

      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 180,
          colors: [['rgba(0,0,0,0.3)', 0.0], ['rgba(0,0,0,0.7)', 1.0]]
        })
        .expandSafeArea()
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .expandSafeArea()
  }

  @Builder
  ProgressBar() {
    Column() {
      Text(this.formatTime(this.currentTime))
        .fontSize(12)
        .fontColor('rgba(255, 255, 255, 0.6)')

      Slider({
        value: this.currentTime,
        max: this.duration || 100,
        step: 1,
        style: SliderStyle.NONE
      })
        .trackThickness(this.isProgressBarExpanded ? 12 : 4)
        .selectedColor(Color.White)
        .trackColor('rgba(255, 255, 255, 0.3)')
        .width('100%')
        .onChange((value: number) => {
          this.currentTime = value
        })
        .onTouch((event) => {
          if (event.type === TouchType.Down) {
            this.isProgressBarExpanded = true
          } else if (event.type === TouchType.Up) {
            this.isProgressBarExpanded = false
            this.playerManager.getAVPlayerInstance().then(player => {
              player.seek(this.currentTime)
            })
          }
        })

      Text(this.formatTime(this.duration))
        .fontSize(12)
        .fontColor('rgba(255, 255, 255, 0.6)')
    }
    .padding(16)
    .width('100%')
  }

  private coverWidth = new BreakPointType({
    sm: '85%',
    md: '75%',
    lg: '65%'
  })
  private buttonSize = new BreakPointType({
    sm: 48,
    md: 56,
    lg: 64
  })

  @Builder
  PlayerControls() {
    Row() {
      Button({ type: ButtonType.Circle }) {
        Image($r('app.media.ic_prev'))
          .width(40)
          .height(40)
          .fillColor(Color.White)
      }
      .width(this.buttonSize.getValue(this.currentBreakpoint))
      .height(this.buttonSize.getValue(this.currentBreakpoint))
      .margin(12)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        globalPlaylist.playPrevious()
      })

      Button({ type: ButtonType.Circle }) {
        Image(this.isPlaying ? $r('app.media.ic_pause') : $r('app.media.ic_play'))
          .width(44)
          .height(44)
          .fillColor(Color.White)
      }
      .width(this.buttonSize.getValue(this.currentBreakpoint) + 20)
      .height(this.buttonSize.getValue(this.currentBreakpoint) + 20)
      .margin(12)
      .backgroundColor('rgba(255, 255, 255, 0.1)')
      .onClick(() => {
        if (this.isPlaying) {
          this.playerManager.pause()
        } else {
          this.playerManager.play()
        }
      })

      Button({ type: ButtonType.Circle }) {
        Image($r('app.media.ic_next'))
          .width(40)
          .height(40)
          .fillColor(Color.White)
      }
      .width(this.buttonSize.getValue(this.currentBreakpoint))
      .height(this.buttonSize.getValue(this.currentBreakpoint))
      .margin(12)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        globalPlaylist.playNext()
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  ActionControls() {
    Row({ space: 8 }) {
      Button({ type: ButtonType.Circle }) {
        Image(this.getPlayModeResource(this.playMode))
          .width(28)
          .height(28)
          .fillColor(Color.White)
      }
      .width(44)
      .height(44)
      .margin(8)
      .backgroundColor('rgba(255, 255, 255, 0.1)')
      .onClick(() => {
        this.playMode = globalPlaylist.switchPlayMode()
      })

      Button({ type: ButtonType.Circle }) {
        Image(this.isFavorite ? $r('app.media.ic_heart_fill') : $r('app.media.ic_heart'))
          .width(28)
          .height(28)
          .fillColor(this.isFavorite ? '#FF4081' : Color.White)
      }
      .width(44)
      .height(44)
      .margin(8)
      .backgroundColor('rgba(255, 255, 255, 0.1)')
      .onClick(() => {
        EventBus.send("ToggleFavorite")
      })

      Button({ type: ButtonType.Circle }) {
        Image($r('app.media.ic_list'))
          .width(28)
          .height(28)
          .fillColor(Color.White)
      }
      .width(44)
      .height(44)
      .margin(8)
      .backgroundColor('rgba(255, 255, 255, 0.1)')
      .onClick(() => {
        this.showPlaylist = true;
        //promptAction.showToast({ message: "存在性能问题，暂时禁用" })
      })
    }
    .margin({ top: 16 })
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  getPlayModeResource(playMode: PlayMode) {
    switch (playMode) {
      case PlayMode.SEQUENCE:
        return $r('app.media.ic_order_play')
      case PlayMode.RANDOM:
        return $r('app.media.ic_shuffle')
      case PlayMode.LOOP:
        return $r('app.media.ic_repeat')
      case PlayMode.SINGLE:
        return $r('app.media.ic_repeat_1')
      default:
        return $r('app.media.ic_order_play')
    }
  }

  build() {
    Stack() {
      this.BlurBackground()

      Column() {
        if (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG) {
          Row() {
            Column() {
              Image(cover(this.track?.track.al.picUrl ?? "", 512))
                .width(this.coverWidth.getValue(this.currentBreakpoint))
                .aspectRatio(1)
                .borderRadius(24)
                .margin({ top: 48 })
                .shadow({ radius: 24, color: 'rgba(0, 0, 0, 0.2)', offsetY: 12 })

              Text(this.track?.track.name)
                .fontSize(this.getFontSize(this.track?.track.name ?? "", 28, 24))
                .fontWeight(FontWeight.Bold)
                .maxLines(1)
                .margin({ top: 24 })
                .fontColor(Color.White)

              Text(this.track?.track.ar.map(item => item.name).join(" / "))
                .fontSize(16)
                .fontColor('rgba(255, 255, 255, 0.6)')
                .margin({ top: 8 })

              this.ProgressBar()
              this.PlayerControls()
              this.ActionControls()
            }
            .width('60%')
            .height('100%')
            .alignItems(HorizontalAlign.Center)

            Column() {
              List() {
                ListItem() {
                  Text("正在努力施工中...")
                    .fontSize(16)
                    .margin(8)
                    .fontColor(Color.White)
                }
              }
              .width('100%')
            }
            .width('40%')
            .height('100%')
            .backgroundColor('rgba(255, 255, 255, 0.1)')
            .backdropBlur(20)
            .borderRadius(32)
            .expandSafeArea()
            .padding(16)
          }
          .expandSafeArea()
        } else {
          Tabs({ barPosition: BarPosition.End, index: this.selectedTabIndex }) {
            TabContent() {
              Column() {
                Image(cover(this.track?.track.al.picUrl ?? "", 512))
                  .width(this.coverWidth.getValue(this.currentBreakpoint))
                  .aspectRatio(1)
                  .borderRadius(24)
                  .margin({ top: 48 })
                  .shadow({ radius: 24, color: 'rgba(0, 0, 0, 0.2)', offsetY: 12 })

                Text(this.track?.track.name)
                  .fontSize(this.getFontSize(this.track?.track.name ?? "", 28, 24))
                  .fontWeight(FontWeight.Bold)
                  .maxLines(1)
                  .margin({ top: 24 })
                  .fontColor(Color.White)

                Text(this.track?.track.ar.map(item => item.name).join(" / "))
                  .fontSize(16)
                  .fontColor('rgba(255, 255, 255, 0.6)')
                  .margin({ top: 8 })

                this.ProgressBar()
                this.PlayerControls()
                this.ActionControls()
              }
              .width('100%')
              .height('100%')
              .alignItems(HorizontalAlign.Center)
            }
            .expandSafeArea()

            TabContent() {
              Column() {
                List() {
                  ListItem() {
                    Text("正在努力施工中...")
                      .fontSize(16)
                      .margin(8)
                      .fontColor(Color.White)
                  }
                }
                .width('100%')
              }
              .width('100%')
              .height('100%')
              .backgroundColor('rgba(255, 255, 255, 0.1)')
              .backdropBlur(20)
              .borderRadius(32)
              .expandSafeArea()
              .padding(16)
            }
            .expandSafeArea()
          }
          .scrollable(true)
          .clip(false)
          .barHeight(0)
          .onChange((index: number) => {
            this.selectedTabIndex = index
          })
        }
      }
    }
    .width('100%')
    .height('100%')
    .expandSafeArea()
    .bindSheet($$this.showPlaylist, this.PlayListBuilder(), {
      showClose: false,
      detents: [SheetSize.MEDIUM, SheetSize.LARGE],
      dragBar: false,
      scrollSizeMode: ScrollSizeMode.CONTINUOUS
    })
  }
}