import { AxiosResponse } from "@ohos/axios";
import { PreferencesUtil } from "../common/PreferenceUtil";
import {getRequest} from "../common/RequestUtil";
import { DailySong, LyricResponse, SongDetailResponse, SongUrlResponse } from "../type/Song";

// 获取歌曲详情 API
export async function getSongDetail(ids: Array<number | string>): Promise<SongDetailResponse> {
  const request = getRequest()
  const response: AxiosResponse = await request.post(`/song/detail?ids=${ids.join(",")}`);
  return response.data as SongDetailResponse;
}

// 获取音乐URL API
export async function getSongUrl(
  id: string | number,
  level = PreferencesUtil.get<string>("defaultLevel") ?? "standard"
): Promise<SongUrlResponse> {
  const request = getRequest()
  const response: AxiosResponse = await request.post(`/song/url/v1?id=${id}&level=${level}`);
  return response.data as SongUrlResponse;
}

export async function likeSong(id: number | string, like: boolean) {
  const request = getRequest()
  await request.post(`/like?id=${id}&like=${like}`);
}

interface LovedIds {
  ids: Array<number | string>
}

export async function checkIfLoved(songId: number | string) {
  const request = getRequest()
  const response: AxiosResponse = await request.post(`/song/like/check?ids=[${songId}]`);
  const data = response.data as LovedIds;
  return data.ids.includes(songId)
}

interface RecommendSongs {
  dailySongs: DailySong[];
}

interface RecommendSongsData {
  code: number;
  data: RecommendSongs;
}

export async function getRecommendSongs(): Promise<RecommendSongsData> {
  const request = getRequest()
  const response: AxiosResponse = await request.post('/recommend/songs')
  return response.data as RecommendSongsData;
}

export async function playlistSubscribe(id: string | number, t: number) {
  const request = getRequest()
  await request.post(`/playlist/subscribe?t=${t}&id=${id}`)
}

/**
 * 获取歌词的API
 * @param id 歌曲id
 * @returns 歌词数据
 */
export async function getSongLyric(id: string | number): Promise<LyricResponse> {
  const request = getRequest()
  const response: AxiosResponse = await request.post(`/lyric?id=${id}`);
  return response.data as LyricResponse;
}

// 收藏/取消收藏歌曲到歌单
export async function collectSong(pid: number | string, ids: Array<number | string>, op: "add" | "del" = "add") {
  const request = getRequest()
  await request.post(`/playlist/tracks?op=${op}&pid=${pid}&tracks=${ids.join(",")}`);
}