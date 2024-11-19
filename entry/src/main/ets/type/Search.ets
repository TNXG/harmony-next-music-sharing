import { SongDetail } from "./Song";

// 搜索结果
export interface SearchResult {
  searchQcReminder: null | string;
  songs: SongDetail[];
}

export interface SearchResponse {
  result: SearchResult
  code: number
}

// 搜索类型枚举
export enum SearchType {
  SINGLE = 1,
  ALBUM = 10,
  ARTIST = 100,
  PLAYLIST = 1000,
  USER = 1002,
  MV = 1004,
  LYRIC = 1006,
  RADIO = 1009,
  VIDEO = 1014,
  COMPREHENSIVE = 1018
}

// 搜索参数
export interface SearchParams {
  keywords: string;
  limit?: number;
  offset?: number;
  type?: SearchType;
}