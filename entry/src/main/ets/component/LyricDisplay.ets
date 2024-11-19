import { avPlayerManager } from "../common/AVPlayerManager"
import { LyricLine, LyricResponse } from '../type/Song'
import { EventBus } from '../common/EventBus'
import { BreakPointType } from "../common/BreakpointSystem"
import { PreferencesUtil } from "../common/PreferenceUtil";

interface Lyric {
  time: number;
  text: string;
  translation: string;
}

interface HighlightStyle {
  fontSize: number;
  fontWeight: FontWeight;
  fontColor: ResourceStr;
  background: string;
}

@Component
export struct LyricView {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm'
  @StorageLink('Lyrics') lyrics: LyricResponse | null = null
  @State private parsedLyrics: Array<Lyric> = []
  @State private currentTime: number = 0
  @State private isUserScrolling: boolean = false
  @State private currentIndex: number = -1
  @State private highlightProgress: number = 0
  @State private fontSize: number = PreferencesUtil.get("lyricSize") ?? 1
  private scroller: Scroller = new Scroller()
  private userScrollTimer: number = -1
  private updateTimer: number = -1
  private playerManager = avPlayerManager
  private readonly ANIMATION_DURATION: number = 300
  // 基础字号配置
  private baseFontSize = new BreakPointType({
    sm: 18,
    md: 20,
    lg: 22
  })
  private baseFontSizeTranslation = new BreakPointType({
    sm: 16,
    md: 18,
    lg: 20
  })

  private parseLyric(lrc: string): Array<LyricLine> {
    const lyrics: Array<LyricLine> = []
    const lines = lrc.split('\n')
    const timeRegex = /\[(\d{2}):(\d{2})\.(\d{2,3})\]/

    lines.forEach(line => {
      const match = timeRegex.exec(line)
      if (match) {
        const minutes = parseInt(match[1])
        const seconds = parseInt(match[2])
        const ms = parseInt(match[3])
        const time = minutes * 60 * 1000 + seconds * 1000 + (ms < 100 ? ms * 10 : ms)
        const text = line.replace(timeRegex, '').trim()
        if (text) {
          lyrics.push({ time, text })
        }
      }
    })

    return lyrics.sort((a, b) => a.time - b.time)
  }

  private updateParsedLyrics() {
    if (!this.lyrics) {
      this.parsedLyrics = []
      return
    }

    const originLyrics = this.parseLyric(this.lyrics.lrc?.lyric || '')
    const translationLyrics = this.parseLyric(this.lyrics.tlyric?.lyric || '')

    this.parsedLyrics = originLyrics.map(item => {
      const trans = translationLyrics.find(t => Math.abs(t.time - item.time) < 100)
      return {
        time: item.time,
        text: item.text,
        translation: trans?.text || ''
      } as Lyric
    })
  }

  // 计算高亮程度（0-1之间）
  private calculateHighlightProgress(currentTime: number, startTime: number, endTime: number): number {
    const duration = endTime - startTime
    const elapsed = currentTime - startTime
    return Math.min(1, Math.max(0, elapsed / Math.min(duration, this.ANIMATION_DURATION)))
  }

  // 更新当前高亮的歌词索引
  private updateCurrentIndex(currentTime: number) {
    let newIndex = this.parsedLyrics.findIndex((item, index) => {
      const nextItem = this.parsedLyrics[index + 1]
      return currentTime >= item.time && (!nextItem || currentTime < nextItem.time)
    })

    if (newIndex !== -1) {
      // 计算过渡动画进度
      const currentLyric = this.parsedLyrics[newIndex]
      const nextLyric = this.parsedLyrics[newIndex + 1]
      const endTime = nextLyric ? nextLyric.time : currentLyric.time + 5000 // 如果是最后一句，假设持续5秒

      this.highlightProgress = this.calculateHighlightProgress(
        currentTime,
        currentLyric.time,
        endTime
      )

      if (newIndex !== this.currentIndex) {
        this.currentIndex = newIndex
        // 只在用户不滚动时自动滚动
        if (!this.isUserScrolling) {
          this.scroller.scrollToIndex(Math.max(0, newIndex - 3))
        }
      }
    }
  }

  aboutToAppear() {
    this.updateParsedLyrics()

    EventBus.listen<LyricResponse>('LyricsUpdated', (lyrics) => {
      this.updateParsedLyrics()
    })

    this.updateTimer = setInterval(async () => {
      const player = await this.playerManager.getAVPlayerInstance()
      this.currentTime = player.currentTime
      this.updateCurrentIndex(this.currentTime)
    }, 50)
  }

  aboutToDisappear() {
    if (this.updateTimer !== -1) {
      clearInterval(this.updateTimer)
    }
    if (this.userScrollTimer !== -1) {
      clearTimeout(this.userScrollTimer)
    }
  }

  // 计算高亮样式
  private getHighlightStyle(index: number): HighlightStyle {
    const isCurrentLine = index === this.currentIndex
    const progress = isCurrentLine ? this.highlightProgress : 0
    const baseFontSize = this.baseFontSize.getValue(this.currentBreakpoint)
    const adjustedFontSize = baseFontSize * this.fontSize

    return {
      fontSize: adjustedFontSize + (4 * progress * this.fontSize),
      fontWeight: isCurrentLine ? FontWeight.Bold : FontWeight.Normal,
      fontColor: isCurrentLine ? Color.White : 'rgba(255, 255, 255, 0.5)',
      background: isCurrentLine ? `rgba(255, 255, 255, )` : 'transparent'
    } as HighlightStyle
  }

  @Builder
  FontSizeControls() {
    Row() {
      Button({ type: ButtonType.Circle, stateEffect: true }) {
        Image($r('app.media.ic_font_decrease'))
          .width(24)
          .height(24)
          .fillColor("rgba(255, 255, 255, 0.5)")
      }
      .width(36)
      .height(36)
      .backgroundColor(Color.Transparent)
      .enabled(this.fontSize > 0.6)
      .onClick(() => {
        this.fontSize = Math.max(0.8, this.fontSize - 0.2)
        PreferencesUtil.put("lyricSize", this.fontSize)
      })

      Text()
        .width(1)
        .height(24)
        .backgroundColor($r('app.color.border_color'))
        .margin({ left: 6, right: 6 })
        .opacity(0.6)

      Button({ type: ButtonType.Circle, stateEffect: true }) {
        Image($r('app.media.ic_font_increase'))
          .width(24)
          .height(24)
          .fillColor("rgba(255, 255, 255, 0.5)")
      }
      .width(36)
      .height(36)
      .backgroundColor(Color.Transparent)
      .enabled(this.fontSize < 5)
      .onClick(() => {
        this.fontSize = Math.min(5, this.fontSize + 0.2)
        PreferencesUtil.put("lyricSize", this.fontSize)
      })
    }
    .height(48)
    .width('100%')
    .justifyContent(FlexAlign.End)
    .backgroundColor(Color.Transparent)
    .borderRadius({ topLeft: 12, topRight: 12 })
  }

  build() {
    Stack() {
      Column() {
        if (this.parsedLyrics.length === 0) {
          Text('暂无歌词')
            .fontSize(this.baseFontSize.getValue(this.currentBreakpoint) * this.fontSize)
            .fontColor($r('app.color.text_secondary'))
            .margin(16)
        } else {
          List({ scroller: this.scroller }) {
            ListItem().height(160)

            ForEach(this.parsedLyrics, (item: Lyric, index) => {
              ListItem() {
                Column() {
                  Text(item.text)
                    .fontSize(this.getHighlightStyle(index).fontSize)
                    .fontWeight(this.getHighlightStyle(index).fontWeight)
                    .fontColor(this.getHighlightStyle(index).fontColor)
                    .margin({ top: 8, bottom: item.translation ? 4 : 8 })
                    .textAlign(TextAlign.Start)
                    .alignSelf(ItemAlign.Start)
                    .animation({
                      duration: 300,
                      curve: Curve.EaseInOut
                    })
                    .onClick(() => {
                      this.playerManager.getAVPlayerInstance().then(player => {
                        player.seek(item.time)
                      })
                    })

                  if (item.translation) {
                    Text(item.translation)
                      .fontSize(this.baseFontSizeTranslation.getValue(this.currentBreakpoint) * this.fontSize)
                      .fontWeight(this.getHighlightStyle(index).fontWeight)
                      .fontColor(this.getHighlightStyle(index).fontColor)
                      .margin({ bottom: 8 })
                      .textAlign(TextAlign.Start)
                      .alignSelf(ItemAlign.Start)
                      .animation({
                        duration: 300,
                        curve: Curve.EaseInOut
                      })
                      .onClick(() => {
                        this.playerManager.getAVPlayerInstance().then(player => {
                          player.seek(item.time)
                        })
                      })
                  }
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
                .padding({ left: 32, right: 32 })
                .backgroundColor(this.getHighlightStyle(index).background)
                .borderRadius(8)
                .animation({
                  duration: 300,
                  curve: Curve.EaseInOut
                })
              }
            })
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .onWillScroll((scrollOffset: number, scrollState: ScrollState) => {
            this.isUserScrolling = true
            if (this.userScrollTimer !== -1) {
              clearTimeout(this.userScrollTimer)
            }
            this.userScrollTimer = setTimeout(() => {
              this.isUserScrolling = false
            }, 3000)
          })
        }
      }
      .width('100%')
      .height('100%')

      // 固定在底部的字号控制栏
      Column() {
        this.FontSizeControls()
      }
      .position({ x: 0, y: '100%' })
      .translate({ y: -16 })  // 控制栏高度
      .width('100%')
    }
    .width('100%')
    .height('100%')
  }
}