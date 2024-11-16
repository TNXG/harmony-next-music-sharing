import { AxiosResponse } from "@ohos/axios"
import { PreferencesUtil } from "../common/PreferenceUtil";
import { request } from "../common/RequestUtil"
import { AccountProfile } from "../type/Account"
import StatsResponse, { PlaylistDetailResponse, UserPlaylistResponse } from "../type/Playlist"

export async function getUserPlaylist() {
  const profile: AccountProfile = PreferencesUtil.get<AccountProfile>("profile");
  if (!profile) {
    // 未登录避免一些额外的闪退或者重复提示直接返回空结果
    return {
      more: false,
      code: 403,
      playlist: [],
    } as UserPlaylistResponse
  }
  const res: AxiosResponse = await request.post(`/user/playlist?uid=${profile.userId}`)
  const data = res.data as UserPlaylistResponse
  return data
}

export async function getPlayListDetail(id: number | string) {
  const res: AxiosResponse = await request.post(`/playlist/detail?id=${id}`)
  const data = res.data as PlaylistDetailResponse
  return data
}

export async function getPlayListDetailDynamic(id: number | string) {
  const res: AxiosResponse = await request.post(`/playlist/detail/dynamic?id=${id}`)
  const data = res.data as StatsResponse
  return data
}