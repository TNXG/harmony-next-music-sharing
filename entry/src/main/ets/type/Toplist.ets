/**
 * 歌手排行榜相关资源信息
 */
export interface RelatedResource {
  /** 资源图标 */
  icon?: string;
  /** 资源标题 */
  title?: string;
  /** 资源副标题 */
  subTitle?: string;
  /** 资源链接 */
  url?: string;
  /** 资源ID */
  resId?: string;
  /** 资源类型 */
  resType?: string;
}

/**
 * 歌手信息
 */
export interface Artist {
  /** 歌手姓名 */
  name: string;
  /** 歌手ID */
  id: number;
  /** 歌手图片ID */
  picId: number;
  /** 1v1图片ID */
  img1v1Id: number;
  /** 歌手简介 */
  briefDesc: string;
  /** 歌手图片URL */
  picUrl: string;
  /** 1v1图片URL */
  img1v1Url: string;
  /** 专辑数量 */
  albumSize: number;
  /** 歌手别名 */
  alias: string[];
  /** 歌手翻译名 */
  trans: string;
  /** 音乐数量 */
  musicSize: number;
  /** 话题人数 */
  topicPerson: number;
  /** 上次排名 */
  lastRank: number;
  /** 得分 */
  score: number;
  /** 图片ID字符串 */
  picId_str?: string;
  /** 1v1图片ID字符串 */
  img1v1Id_str?: string;
  /** 翻译名数组 */
  transNames?: string[];
  /** 相关资源 */
  relatedRes: RelatedResource | null;
}

/**
 * 歌手列表信息
 */
export interface ArtistList {
  /** 歌手数组 */
  artists: Artist[];
  /** 更新时间 */
  updateTime: number;
  /** 类型 */
  type: number;
}

/**
 * 歌手排行榜接口响应
 */
export interface ArtistRankResponse {
  /** 返回码 */
  code: number;
  /** 歌手列表信息 */
  list: ArtistList;
}

/**
 * 榜单详情信息
 */
export interface Playlist {
  // /** 订阅者 */
  // subscribers: any[];
  /** 是否订阅 */
  subscribed: boolean | null;
  /** 创建者 */
  creator: null;
  /** 歌手列表 */
  artists: null;
  /** 歌曲列表 */
  tracks: null;
  /** 更新频率 */
  updateFrequency: string;
  /** 背景封面ID */
  backgroundCoverId: number;
  /** 背景封面URL */
  backgroundCoverUrl: string | null;
  /** 标题图片 */
  titleImage: number;
  /** 封面文字 */
  coverText: string | null;
  /** 标题图片URL */
  titleImageUrl: string | null;
  /** 封面图片URL */
  coverImageUrl: string | null;
  /** 图标图片URL */
  iconImageUrl: string | null;
  /** 英文标题 */
  englishTitle: string | null;
  /** 官方推荐 */
  opRecommend: boolean;
  /** 推荐信息 */
  recommendInfo: null;
  /** 社交歌单封面 */
  socialPlaylistCover: null;
  /** 歌曲数量 */
  tsSongCount: number;
  /** 算法类型 */
  algType: null;
  /** 是否精品 */
  highQuality: boolean;
  /** 特殊类型 */
  specialType: number;
  /** 封面图片ID */
  coverImgId: number;
  /** 是否新导入 */
  newImported: boolean;
  /** 是否匿名 */
  anonimous: boolean;
  /** 更新时间 */
  updateTime: number;
  /** 歌曲数量 */
  trackCount: number;
  /** 评论线程ID */
  commentThreadId: string;
  /** 歌曲更新时间 */
  trackUpdateTime: number;
  /** 封面图片URL */
  coverImgUrl: string;
  /** 总时长 */
  totalDuration: number;
  /** 播放次数 */
  playCount: number;
  /** 歌曲数量更新时间 */
  trackNumberUpdateTime: number;
  /** 隐私设置 */
  privacy: number;
  /** 广告类型 */
  adType: number;
  /** 订阅数量 */
  subscribedCount: number;
  /** 云盘歌曲数量 */
  cloudTrackCount: number;
  /** 创建时间 */
  createTime: number;
  /** 是否有序 */
  ordered: boolean;
  /** 描述 */
  description: string | null;
  /** 状态 */
  status: number;
  /** 标签 */
  tags: string[];
  /** 用户ID */
  userId: number;
  /** 榜单名称 */
  name: string;
  /** 榜单ID */
  id: number;
  /** 封面图片ID字符串 */
  coverImgId_str?: string;
  /** 榜单类型 */
  ToplistType?: string;
}

/**
 * 歌手榜单信息
 */
export interface ArtistToplist {
  /** 封面URL */
  coverUrl: string;
  /** 榜单名称 */
  name: string;
  /** 更新频率 */
  updateFrequency: string;
  /** 位置 */
  position: number;
  /** 更新频率（遗留字段） */
  upateFrequency: string;
}

/**
 * 榜单列表响应接口
 */
export interface ToplistResponse {
  /** 响应码 */
  code: number;
  /** 榜单列表 */
  list: Playlist[];
  /** 歌手榜单信息 */
  artistToplist: ArtistToplist;
}