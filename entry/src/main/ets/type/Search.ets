import { SongDetail } from "./Song";

@Observed
export class SearchResult {
  searchQcReminder: null | string = null;
  songs: SongDetail[] = [];

  constructor(result?: SearchResult) {
    if (result !== undefined) {
      this.searchQcReminder = result.searchQcReminder;
      this.songs = result.songs.map(song => new SongDetail(song));
    }
  }
}

@Observed
export class SearchResponse {
  result: SearchResult = new SearchResult();
  code: number = 0;

  constructor(response?: SearchResponse) {
    if (response !== undefined) {
      this.result = new SearchResult(response.result);
      this.code = response.code;
    }
  }
}

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

export interface  SearchParams {
  keywords: string;
  limit?: number;
  offset?: number;
  type?: SearchType;
}