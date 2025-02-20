import { LyricLine, LyricResponse } from '../type/Song'

interface ParsedLyric {
  time: number
  text: string
  translation: string
}

export interface LyricMetadata {
  title: string
  artist: string
  album: string
  by: string
  offset: number
  length: string
}

interface Progress {
  index: number;
  progress: number;
}

export class LyricParser {
  /**
   * 解析歌词字符串为结构化数据
   * @param lrc 歌词字符串
   * @returns 解析后的歌词数组
   */
  private static parseLyricText(lrc: string): Array<LyricLine> {
    const lyrics: Array<LyricLine> = []
    const lines: string[] = lrc.split('\n')
    const timeRegex: RegExp = /\[(\d{2}):(\d{2})\.(\d{2,3})\]/

    lines.forEach((line: string) => {
      const match: RegExpExecArray | null = timeRegex.exec(line)
      if (match) {
        const minutes: number = parseInt(match[1])
        const seconds: number = parseInt(match[2])
        const ms: number = parseInt(match[3])
        const time: number = minutes * 60 * 1000 + seconds * 1000 + (ms < 100 ? ms * 10 : ms)
        const text: string = line.replace(timeRegex, '').trim()
        if (text) {
          const lyricLine: LyricLine = new LyricLine()
          lyricLine.time = time
          lyricLine.text = text
          lyrics.push(lyricLine)
        }
      }
    })

    return lyrics.sort((a: LyricLine, b: LyricLine): number => a.time - b.time)
  }

  /**
   * 解析包含原文和翻译的完整歌词数据
   * @param lyricData 歌词数据对象
   * @returns 解析后的歌词数组，包含原文和翻译
   */
  static parseLyrics(lyricData: LyricResponse | null): Array<ParsedLyric> {
    if (!lyricData) {
      return []
    }

    const originLyrics: Array<LyricLine> = LyricParser.parseLyricText(lyricData.lrc?.lyric || '')
    const translationLyrics: Array<LyricLine> = LyricParser.parseLyricText(lyricData.tlyric?.lyric || '')

    return originLyrics.map((item: LyricLine): ParsedLyric => {
      const trans: LyricLine | undefined = translationLyrics.find((t: LyricLine): boolean =>
      Math.abs(t.time - item.time) < 100
      )
      return {
        time: item.time,
        text: item.text,
        translation: trans?.text || ''
      }
    })
  }

  /**
   * 获取当前时间对应的歌词索引和进度信息
   * @param currentTime 当前播放时间
   * @param lyrics 解析后的歌词数组
   * @param animationDuration 动画持续时间
   * @returns 当前歌词信息
   */
  static getCurrentLyricInfo(
    currentTime: number,
    lyrics: Array<ParsedLyric>,
    animationDuration: number = 300
  ): Progress {
    const currentIndex: number = lyrics.findIndex((item: ParsedLyric, index: number): boolean => {
      const nextItem: ParsedLyric | undefined = lyrics[index + 1]
      return currentTime >= item.time && (!nextItem || currentTime < nextItem.time)
    })

    if (currentIndex === -1) {
      return { index: -1, progress: 0 }
    }

    const currentLyric: ParsedLyric = lyrics[currentIndex]
    const nextLyric: ParsedLyric | undefined = lyrics[currentIndex + 1]
    const endTime: number = nextLyric ? nextLyric.time : currentLyric.time + 5000

    // 计算高亮进度
    const duration: number = endTime - currentLyric.time
    const elapsed: number = currentTime - currentLyric.time
    const progress: number = Math.min(1, Math.max(0, elapsed / Math.min(duration, animationDuration)))

    return {
      index: currentIndex,
      progress: progress
    }
  }

  /**
   * 获取当前时刻的具体歌词对象
   * @param currentTime 当前播放时间
   * @param lyrics 解析后的歌词数组
   * @returns 当前歌词对象，若未找到则返回null
   */
  static getCurrentLyric(
    currentTime: number,
    lyrics: Array<ParsedLyric>
  ): ParsedLyric | null {
    const currentIndex: number = lyrics.findIndex((item: ParsedLyric, index: number): boolean => {
      const nextItem: ParsedLyric | undefined = lyrics[index + 1]
      return currentTime >= item.time && (!nextItem || currentTime < nextItem.time)
    })

    return currentIndex !== -1 ? lyrics[currentIndex] : null
  }

  /**
   * 将歌词数据转换为标准的LRC格式
   * @param lyrics 解析后的歌词数组
   * @param metadata 歌词元数据
   * @returns 标准LRC格式的字符串
   */
  static convertToLRC(lyrics: Array<ParsedLyric>, translation?: boolean,metadata?: LyricMetadata): string {
    const lines: Array<string> = []

    // 添加元数据标签
    if (metadata) {
      if (metadata.title) {
        lines.push(`[ti:${metadata.title}]`)
      }
      if (metadata.artist) {
        lines.push(`[ar:${metadata.artist}]`)
      }
      if (metadata.album) {
        lines.push(`[al:${metadata.album}]`)
      }
      if (metadata.by) {
        lines.push(`[by:${metadata.by}]`)
      }
      lines.push(`[offset:${metadata.offset}]`)
      if (metadata.length) {
        lines.push(`[length:${metadata.length}]`)
      }
      lines.push('')  // 空行分隔元数据和歌词
    }

    const formatTime = (ms: number): string => {
      const totalSeconds: number = Math.floor(ms / 1000)
      const minutes: number = Math.floor(totalSeconds / 60)
      const seconds: number = totalSeconds % 60
      const milliseconds: number = ms % 1000

      const minutesStr: string = minutes < 10 ? `0${minutes}` : `${minutes}`
      const secondsStr: string = seconds < 10 ? `0${seconds}` : `${seconds}`
      const msStr: string = milliseconds < 10 ? `0${milliseconds}` : `${milliseconds}`

      return `${minutesStr}:${secondsStr}.${msStr.slice(0, 2)}`
    }

    // 添加歌词行
    lyrics.forEach((line: ParsedLyric) => {
      // 添加原文歌词
      lines.push(`[${formatTime(line.time)}]${line.text}`)

      // 如果有翻译，添加翻译行
      if ( translation && line.translation) {
        lines.push(`[${formatTime(line.time)}]${line.translation}`)
      }
    })

    return lines.join('\n')
  }

  /**
   * 批量添加时间偏移
   * @param lyrics 解析后的歌词数组
   * @param offset 时间偏移量（毫秒）
   * @returns 新的歌词数组
   */
  static addTimeOffset(lyrics: Array<ParsedLyric>, offset: number): Array<ParsedLyric> {
    return lyrics.map((line: ParsedLyric): ParsedLyric => {
      const newLine: ParsedLyric = {
        time: line.time + offset,
        text: line.text,
        translation: line.translation
      }
      return newLine
    })
  }

  /**
   * 从LRC格式字符串解析元数据
   * @param lrcContent LRC格式的歌词字符串
   * @returns 解析出的元数据
   */
  static parseMetadata(lrcContent: string): LyricMetadata {
    const metadata: LyricMetadata = {
      title: '',
      artist: '',
      album: '',
      by: '',
      offset: 0,
      length: ''
    }

    const lines: Array<string> = lrcContent.split('\n')
    const titleRegex: RegExp = /\[ti:(.*?)\]/
    const artistRegex: RegExp = /\[ar:(.*?)\]/
    const albumRegex: RegExp = /\[al:(.*?)\]/
    const byRegex: RegExp = /\[by:(.*?)\]/
    const offsetRegex: RegExp = /\[offset:(.*?)\]/
    const lengthRegex: RegExp = /\[length:(.*?)\]/

    lines.forEach((line: string) => {
      let match: RegExpExecArray | null = null

      if ((match = titleRegex.exec(line)) !== null) {
        metadata.title = match[1]
      } else if ((match = artistRegex.exec(line)) !== null) {
        metadata.artist = match[1]
      } else if ((match = albumRegex.exec(line)) !== null) {
        metadata.album = match[1]
      } else if ((match = byRegex.exec(line)) !== null) {
        metadata.by = match[1]
      } else if ((match = offsetRegex.exec(line)) !== null) {
        metadata.offset = parseInt(match[1])
      } else if ((match = lengthRegex.exec(line)) !== null) {
        metadata.length = match[1]
      }
    })

    return metadata
  }
}