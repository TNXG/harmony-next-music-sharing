import { AxiosResponse } from "@ohos/axios"
import { request } from "../common/RequestUtil"
import { FMResponse, Personalized } from "../type/Personalized"

export async function getPersonalizedCollection(limit = 10) {
  const res: AxiosResponse = await request.post(`/personalized?limit=${limit}`)
  return res.data as Personalized
}

export async function getPersonalizedFM() {
  const res: AxiosResponse = await request.post(`/personal_fm`)
  const data = res.data as FMResponse
  data.data.forEach((item) => {
    item.ar = item.artists as ESObject
    item.al = item.album!
  })

  return data
}