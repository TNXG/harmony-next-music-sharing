import { Artist } from "./Toplist";

/**
 * 专辑信息接口
 */
export interface Album {
  /** 歌曲列表 */
  // songs?: []
  /** 是否付费 */
  paid: boolean;
  /** 是否在售 */
  onSale: boolean;
  /** 标记 */
  mark: number;
  /** 获奖标签 */
  awardTags: null;
  /** 专辑艺术家列表 */
  artists: Artist[];
  /** 版权ID */
  copyrightId: number;
  /** 图片ID */
  picId: number;
  /** 主艺术家信息 */
  artist: Artist;
  /** 发布时间 */
  publishTime: number;
  /** 发行公司 */
  company: string;
  /** 简介 */
  briefDesc: string;
  /** 图片URL */
  picUrl: string;
  /** 评论线程ID */
  commentThreadId: string;
  /** 模糊图片URL */
  blurPicUrl: string;
  /** 公司ID */
  companyId: number;
  /** 图片 */
  pic: number;
  /** 状态 */
  status: number;
  /** 专辑类型(录音室版等) */
  subType: string;
  /** 描述 */
  description: string;
  /** 标签 */
  tags: string;
  /** 别名列表 */
  alias: string[];
  /** 专辑名称 */
  name: string;
  /** 专辑ID */
  id: number;
  /** 专辑类型(Single/EP等) */
  type: string;
  /** 歌曲数量 */
  size: number;
  /** 图片ID字符串 */
  picId_str: string;
  /** 翻译名称列表 */
  transNames?: string[];
}

/**
 * 专辑列表响应接口
 */
export interface AlbumListResponse {
  /** 专辑总数 */
  total: number;
  /** 专辑列表 */
  albums: Album[];
  /** 响应码 */
  code: number;
}