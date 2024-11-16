import { AxiosResponse } from "@ohos/axios"
import { request } from "../common/RequestUtil"
import { Personalized } from "../type/Personalized"

export async  function getPersonalizedCollection(limit = 10) {
  const res: AxiosResponse = await request.post(`/personalized?limit=${limit}`)
  return res.data as Personalized
}