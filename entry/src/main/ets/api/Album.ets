import { AxiosResponse } from "@ohos/axios"
import { getRequest } from "../common/RequestUtil"
import { AlbumListResponse } from "../type/Album"

export async  function getNewAlbumList(limit = 10) {
  const request = getRequest()
  const res: AxiosResponse = await request.post(`album/new?limit=${limit}`)
  return res.data as AlbumListResponse
}