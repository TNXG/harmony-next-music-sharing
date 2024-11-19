import { cover } from "../common/APIHelper"
import { avPlayerManager } from "../common/AVPlayerManager"
import { globalPlaylist } from "../common/GlobalPlayListManager"
import { TrackAndPrivilege } from "../type/Playlist"
import { PlayList } from "./PlayList"
import { router } from "@kit.ArkUI"

@Component
export struct PlaybackControlBar {
  @StorageLink('Track') track: TrackAndPrivilege | null = null
  @State currentTime: number = 0
  @State duration: number = 0
  @State isPlaying: boolean = false
  @State isProgressBarExpanded: boolean = false
  @State showPlaylist: boolean = false
  private updateTimer: number = -1
  private playerManager = avPlayerManager

  @Builder
  PlayListBuilder() {
    Column() {
      PlayList({ showPlaylist: $showPlaylist })
    }
    .height("100%")
    .backgroundColor($r('app.color.playlist_bg'))
    .layoutWeight(1)
  }

  aboutToAppear() {
    this.playerManager.getAVPlayerInstance().then(player => {
      this.currentTime = player.currentTime
      this.duration = player.duration
      this.isPlaying = player.state === 'playing'
    })

    this.playerManager.addListener('onPlay', () => {
      this.isPlaying = true
    })

    this.playerManager.addListener('onPause', () => {
      this.isPlaying = false
    })

    this.updateTimer = setInterval(async () => {
      const player = await this.playerManager.getAVPlayerInstance()
      this.currentTime = player.currentTime
      this.duration = player.duration
    }, 500)
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

  @Builder
  ProgressBar() {
    Row() {
      Row({ space: 8 }) {
        Text(this.formatTime(this.currentTime))
          .fontSize(12)
          .fontColor($r('app.color.time_text'))
          .margin({ top: 2 })

        Slider({
          value: this.currentTime,
          max: this.duration || 100,
          step: 1,
          style: SliderStyle.NONE
        })
          .trackThickness(this.isProgressBarExpanded ? 12 : 4)
          .selectedColor($r('app.color.progress_thumb'))
          .trackColor($r('app.color.progress_track'))
          .width("70%")
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
          .fontColor($r('app.color.time_text'))
          .margin({ top: 2 })
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
    }
    .width('100%')
  }

  build() {
    Stack() {
      // 背景色
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.playbar_background'))

      Column({ space: 4 }) {
        // 主控制栏
        Row() {
          // 封面图
          Image(cover(this.track?.track.al.picUrl ?? "", 512))
            .width(52)
            .height(52)
            .borderRadius(8)

          // 标题和艺术家信息
          Column() {
            Text(this.track?.track.name ?? "")
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.song_title'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Text(this.track?.track.ar.map(item => item.name).join(" / ") ?? "")
              .fontSize(13)
              .fontColor($r('app.color.song_artist'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 12 })

          // 控制按钮组
          Row({ space: 4 }) {
            // 上一首
            Button({ type: ButtonType.Circle }) {
              Image($r('app.media.ic_prev'))
                .width(22)
                .height(22)
                .fillColor($r('app.color.song_title'))
            }
            .width(36)
            .height(36)
            .backgroundColor($r('app.color.control_button_bg'))
            .onClick(() => {
              globalPlaylist.playPrevious()
            })

            // 播放/暂停
            Button({ type: ButtonType.Circle }) {
              Image(this.isPlaying ? $r('app.media.ic_pause') : $r('app.media.ic_play'))
                .width(28)
                .height(28)
                .fillColor($r('app.color.song_title'))
            }
            .width(44)
            .height(44)
            .backgroundColor($r('app.color.control_button_bg'))
            .onClick(() => {
              if (this.isPlaying) {
                this.playerManager.pause()
              } else {
                this.playerManager.play()
              }
            })

            // 下一首
            Button({ type: ButtonType.Circle }) {
              Image($r('app.media.ic_next'))
                .width(22)
                .height(22)
                .fillColor($r('app.color.song_title'))
            }
            .width(36)
            .height(36)
            .backgroundColor($r('app.color.control_button_bg'))
            .onClick(() => {
              globalPlaylist.playNext()
            })

            // 播放列表按钮
            Button({ type: ButtonType.Circle }) {
              Image($r('app.media.ic_list'))
                .width(22)
                .height(22)
                .fillColor($r('app.color.song_title'))
            }
            .width(36)
            .height(36)
            .margin({ left: 4 })
            .backgroundColor($r('app.color.control_button_bg'))
            .onClick(() => {
              this.showPlaylist = true
            })
          }
          .margin({ right: 12 })
        }
        .width('100%')
        .height(52)
        .padding({ left: 16, right: 4, top: 16 })
        .justifyContent(FlexAlign.Center)

        // 进度条
        this.ProgressBar()
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height(84)
    .zIndex(999)
    .onClick(()=>{
      router.pushUrl({
        url: "pages/Playing",
      })
    })
    .bindSheet($$this.showPlaylist, this.PlayListBuilder(), {
      showClose: false,
      detents: [SheetSize.MEDIUM, SheetSize.LARGE],
      dragBar: false,
      scrollSizeMode: ScrollSizeMode.CONTINUOUS,
      backgroundColor: $r('app.color.playlist_bg')
    })
  }
}