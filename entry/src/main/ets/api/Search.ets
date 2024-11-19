import { AxiosResponse } from "@ohos/axios";
import { SearchParams, SearchResponse } from "../type/Search";
import { request } from "../common/RequestUtil"

/**
 * 搜索API接口实现
 * @param params 搜索参数
 * @returns Promise<SearchResult>
 */
export async function search(params: SearchParams): Promise<SearchResponse> {
  let queryString: string = "/search?";

  // 构建查询参数
  queryString = queryString + "keywords=" + encodeURIComponent(params.keywords);

  if (params.limit !== undefined) {
    queryString = queryString + "&limit=" + params.limit;
  }

  if (params.offset !== undefined) {
    queryString = queryString + "&offset=" + params.offset;
  }

  if (params.type !== undefined) {
    queryString = queryString + "&type=" + params.type;
  }

  const response: AxiosResponse = await request.post(queryString);
  return response.data as SearchResponse;
}

/**
 * 高级搜索API接口实现
 * @param params 搜索参数
 * @returns Promise<SearchResult>
 */
export async function cloudSearch(params: SearchParams): Promise<SearchResponse> {
  let queryString: string = "/cloudsearch?";

  // 构建查询参数
  queryString = queryString + "keywords=" + encodeURIComponent(params.keywords);

  if (params.limit !== undefined) {
    queryString = queryString + "&limit=" + params.limit;
  }

  if (params.offset !== undefined) {
    queryString = queryString + "&offset=" + params.offset;
  }

  if (params.type !== undefined) {
    queryString = queryString + "&type=" + params.type;
  }

  const response: AxiosResponse = await request.post(queryString);
  return response.data as SearchResponse;
}