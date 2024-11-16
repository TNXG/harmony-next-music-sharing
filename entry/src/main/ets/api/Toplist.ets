import { AxiosResponse } from "@ohos/axios"
import { request } from "../common/RequestUtil"
import { ArtistRankResponse, ToplistResponse } from "../type/Toplist"

export async  function getToplistArtist() {
  const res: AxiosResponse = await request.get(`/toplist/artist`)
  return res.data as ArtistRankResponse
}

export async  function getToplistAlbum() {
  const res: AxiosResponse = await request.get(`/toplist`)
  return res.data as ToplistResponse
}