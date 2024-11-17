import { avPlayerManager } from "../common/AVPlayerManager"
import { LyricLine, LyricResponse } from '../type/Song'
import { EventBus } from '../common/EventBus'

interface Lyric {
  time: number;
  text: string;
  translation: string;
}

interface HighlightStyle {
  fontSize: number;
  fontWeight: FontWeight;
  fontColor: string | Color;
  background: string;
}

@Component
export struct LyricView {
  @StorageLink('Lyrics') lyrics: LyricResponse | null = null
  @State private parsedLyrics: Array<Lyric> = []
  @State private currentTime: number = 0
  @State private isUserScrolling: boolean = false
  @State private currentIndex: number = -1
  @State private highlightProgress: number = 0  // 0到1之间的值，用于动画过渡
  private scroller: Scroller = new Scroller()
  private userScrollTimer: number = -1
  private updateTimer: number = -1
  private playerManager = avPlayerManager
  private readonly ANIMATION_DURATION: number = 300  // 动画持续时间（毫秒）

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
  private getHighlightStyle(index: number) {
    const isCurrentLine = index === this.currentIndex
    const progress = isCurrentLine ? this.highlightProgress : 0

    return ({ fontSize: 20 + (4 * progress),
    fontWeight: isCurrentLine ? FontWeight.Bold : FontWeight.Normal,
    fontColor: isCurrentLine ? Color.White : 'rgba(255, 255, 255, 0.5)',
    background: isCurrentLine ? `rgba(255, 255, 255, )` : 'transparent' } as HighlightStyle)
  }

  build() {
    Column() {
      if (this.parsedLyrics.length === 0) {
        Text('暂无歌词')
          .fontSize(20)
          .fontColor('rgba(255, 255, 255, 0.6)')
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
                    .fontSize(index === this.currentIndex ? 24 : 18)
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

          ListItem().height(160)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .onWillScroll(() => {
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
  }
}