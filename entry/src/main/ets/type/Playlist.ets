import { Album } from "./Album";
import { Artist } from "./Toplist";

/**
 * 持有人类型枚举
 */
export enum ArtistMstEnum {
  /** 普通歌手 */
  NORMAL = 1,
  /** 系统用户 */
  SYS = 2,
  /** 版权方用户 */
  COPYRIGHT = 3
}

/**
 * 音质信息
 */
export interface SongQuality {
  /** 比特率 */
  br: number;

  /** 文件ID */
  fid: number;

  /** 大小 */
  size: number;

  /** 音量调节值 */
  vd: number;

  /** 采样率 */
  sr: number;
}

/**
 * 试听权限
 */
export interface FreeTrialPrivilege {
  /** 是否可消费资源 */
  resConsumable: boolean;

  /** 是否可用户消费 */
  userConsumable: boolean;
  // /** 试听类型 */
  // listenType: any;
  // /** 无法试听原因 */
  // cannotListenReason: any;
  // /** 播放原因 */
  // playReason: any;
  // /** 标签类型 */
  // freeLimitTagType: any;
}

/**
 * 收费信息
 */
export interface ChargeInfo {
  /** 比特率 */
  rate: number;
  // /** 收费链接 */
  // chargeUrl: any;
  // /** 收费信息 */
  // chargeMessage: any;
  // /** 收费类型 */
  // chargeType: number;
}

/**
 * 歌曲播放权限
 */
export interface Privilege {
  /** 歌曲ID */
  id: number;

  /** 费用 */
  fee: number;

  /** 是否付费 */
  payed: number;

  /** 是否实际付费 */
  realPayed: number;

  /** 状态 */
  st: number;

  /** 播放等级 */
  pl: number;

  /** 下载等级 */
  dl: number;

  /** 特殊项 */
  sp: number;

  /** 版权项 */
  cp: number;

  /** 子版权项 */
  subp: number;

  /** 是否cs */
  cs: boolean;

  /** 最大码率 */
  maxbr: number;

  /** 免费等级 */
  fl: number;

  // /** pc信息 */
  // pc: any;
  /** 是否显示toast */
  toast: boolean;

  /** 标记 */
  flag: number;

  /** 是否付费大爆炸 */
  paidBigBang: boolean;

  /** 是否预售 */
  preSell: boolean;

  /** 播放最大码率 */
  playMaxbr: number;

  /** 下载最大码率 */
  downloadMaxbr: number;

  /** 最大音质等级 */
  maxBrLevel: string;

  /** 播放最大音质等级 */
  playMaxBrLevel: string;

  /** 下载最大音质等级 */
  downloadMaxBrLevel: string;

  /** 播放等级 */
  plLevel: string;

  /** 下载等级 */
  dlLevel: string;

  /** 免费等级 */
  flLevel: string;

  // /** 资源列 */
  // rscl: any;
  /** 免费试听权限 */
  freeTrialPrivilege: FreeTrialPrivilege;

  /** 右侧来源 */
  rightSource: number;

  /** 收费信息列表 */
  chargeInfoList: ChargeInfo[];
}

/**
 * 歌曲信息
 */
export interface Track {
  /** 歌曲名称 */
  name: string;

  /** 歌曲ID */
  id: number;

  /** 状态 */
  pst: number;

  /** 类型 */
  t: number;

  /** 歌手列表 */
  ar: Artist[];

  /** 别名列表 */
  alia: string[];

  /** 流行度 */
  pop: number;

  /** 状态 */
  st: number;

  /** rt */
  rt: string;

  /** 费用 */
  fee: number;

  /** 版本 */
  v: number;

  // /** 原唱 */
  // crbt: any;
  /** cf */
  cf: string;

  /** 专辑信息 */
  al: Album;

  /** 时长 */
  dt: number;

  /** 高质量音频信息 */
  h: SongQuality;

  /** 中质量音频信息 */
  m: SongQuality;

  /** 低质量音频信息 */
  l: SongQuality;

  /** 超高质量音频信息 */
  sq: SongQuality;

  /** Hi-Res质量音频信息 */
  hr: SongQuality | null;

  // /** 音频信息 */
  // a: any;
  /** CD序号 */
  cd: string;

  /** 歌曲编号 */
  no: number;

  // /** rtUrl */
  // rtUrl: any;
  /** 文件类型 */
  ftype: number;

  // /** rtUrls */
  // rtUrls: any[];
  /** djId */
  djId: number;

  /** 版权 */
  copyright: number;

  /** s_id */
  s_id: number;

  /** 标记 */
  mark: number;

  /** 原始封面类型 */
  originCoverType: number;

  // /** 原始歌曲简单数据 */
  // originSongSimpleData: any;
  // /** 标签图片列表 */
  // tagPicList: any;
  /** 资源状态 */
  resourceState: boolean;

  /** 版本号 */
  version: number;

  // /** songJumpInfo */
  // songJumpInfo: any;
  // /** entertainmentTags */
  // entertainmentTags: any;
  // /** awardTags */
  // awardTags: any;
  /** 单曲类型 */
  single: number;

  // /** noCopyrightRcmd */
  // noCopyrightRcmd: any;
  // /** 推荐算法 */
  // alg: any;
  // /** 展示原因 */
  // displayReason?: any;
  /** mv id */
  mv: number;

  /** 发布时间 */
  publishTime: number;

  /** 翻译名 */
  tns?: string[];
}

/**
 * 歌曲ID对象
 */
export interface TrackId {
  /** 歌曲ID */
  id: number;

  /** 版本 */
  v: number;

  /** 类型 */
  t: number;

  /** 更新时间 */
  at: number;

  // /** 算法类型 */
  // alg: any;
  /** 用户ID */
  uid: number;

  /** 推荐原因 */
  rcmdReason: string;

  /** 推荐原因标题 */
  rcmdReasonTitle?: string;
}

/**
 * 创建者信息
 */
export interface Creator {
  /** 默认头像 */
  defaultAvatar: boolean;

  /** 省份 */
  province: number;

  /** 认证状态 */
  authStatus: number;

  /** 是否关注 */
  followed: boolean;

  /** 头像URL */
  avatarUrl: string;

  /** 账号状态 */
  accountStatus: number;

  /** 性别 */
  gender: number;

  /** 城市 */
  city: number;

  /** 生日 */
  birthday: number;

  /** 用户ID */
  userId: number;

  /** 用户类型 */
  userType: number;

  /** 昵称 */
  nickname: string;

  /** 签名 */
  signature: string;

  /** 描述 */
  description: string;

  /** 详细描述 */
  detailDescription: string;

  /** 头像ID */
  avatarImgId: number;

  /** 背景图ID */
  backgroundImgId: number;

  /** 背景URL */
  backgroundUrl: string;

  /** 权限 */
  authority: number;

  /** 是否互相关注 */
  mutual: boolean;

  /** 专家标签 */
  // expertTags: any;
  // /** 专家 */
  // experts: any;
  /** dj状态 */
  djStatus: number;

  /** vip类型 */
  vipType: number;

  // /** 备注名 */
  // remarkName: any;
  /** 认证类型 */
  authenticationTypes: number;

  // /** 头像详情 */
  // avatarDetail: any;
  /** 头像ID字符串 */
  avatarImgIdStr: string;

  /** 背景图ID字符串 */
  backgroundImgIdStr: string;

  /** 是否主播 */
  anchor: boolean;
}

/**
 * 单个歌单信息
 */
export interface Playlist {
  // /** 订阅者 */
  // subscribers: any[];
  /** 是否订阅 */
  subscribed: boolean | null;

  /** 创建者 */
  creator: Creator;

  /** 艺术家 */
  artists: Artist[] | null;

  /** 歌曲 */
  tracks: Track[] | null;

  /** 所有歌曲的ID */
  trackIds: TrackId[] | null;

  /** 是否置顶 */
  top: boolean;

  /** 更新频率 */
  updateFrequency: string | null;

  /** 背景封面ID */
  backgroundCoverId: number;

  /** 背景封面URL */
  backgroundCoverUrl: string | null;

  /** 标题图片 */
  titleImage: number;

  /** 标题图片URL */
  titleImageUrl: string | null;

  /** 英文标题 */
  englishTitle: string | null;

  /** 官方推荐 */
  opRecommend: boolean;

  // /** 推荐信息 */
  // recommendInfo: any | null;
  /** 订阅数 */
  subscribedCount: number;

  /** 云盘歌曲数 */
  cloudTrackCount: number;

  /** 创建者ID */
  userId: number;

  /** 总时长 */
  totalDuration: number;

  /** 封面图片ID */
  coverImgId: number;

  /** 隐私设置 */
  privacy: number;

  /** 歌曲更新时间 */
  trackUpdateTime: number;

  /** 歌曲数量 */
  trackCount: number;

  /** 更新时间 */
  updateTime: number;

  /** 评论线程ID */
  commentThreadId: string;

  /** 封面URL */
  coverImgUrl: string;

  /** 特殊类型 */
  specialType: number;

  /** 是否匿名 */
  anonimous: boolean;

  /** 创建时间 */
  createTime: number;

  /** 是否精品 */
  highQuality: boolean;

  /** 是否新导入 */
  newImported: boolean;

  /** 歌曲数量更新时间 */
  trackNumberUpdateTime: number;

  /** 播放数 */
  playCount: number;

  /** 广告类型 */
  adType: number;

  /** 描述 */
  description: string | null;

  /** 标签 */
  tags: string[];

  /** 是否有序 */
  ordered: boolean;

  /** 状态 */
  status: number;

  /** 歌单名称 */
  name: string;

  /** 歌单ID */
  id: number;

  /** 封面图片ID字符串 */
  coverImgId_str?: string;

  // /** 共享用户 */
  // sharedUsers: any | null;
  // /** 共享状态 */
  // shareStatus: any | null;
  /** 是否复制 */
  copied: boolean;

  /** 是否包含歌曲 */
  containsTracks: boolean;

  /** 翻译名称 */
  transNames?: string[];

  // 非官方字段 判断是否有具体信息，如果没有则要进行获取。
  hasBaseInfo?: boolean
}

export interface PlaylistDetailResponse {
  /** 响应码 */
  code: number;

  // /** 相关视频 */
  // relatedVideos: any;
  /** 歌单信息 */
  playlist: Playlist;

  /** 歌曲权限列表 */
  privileges: Privilege[];
}

/**
 * 用户歌单列表响应
 */
export interface UserPlaylistResponse {
  /** 是否还有更多 */
  more: boolean;

  /** 歌单列表 */
  playlist: Playlist[];

  /** 响应码 */
  code: number;
}


/**
 * 简单统计信息响应
 */
export default interface StatsResponse {
  /** 评论数 */
  commentCount: number;

  /** 分享数 */
  shareCount: number;

  /** 播放数 */
  playCount: number;

  /** 收藏数 */
  bookedCount: number;

  /** 是否已订阅 */
  subscribed: boolean;

  /** 备注名 */
  remarkName: string | null;

  /** 是否已关注 */
  followed: boolean;

  /** 等级状态 */
  gradeStatus: string;

  // /** 混音视频 */
  // remixVideo: any | null;
  /** 响应码 */
  code: number;
}

export interface TrackAndPrivilege {
  track: Track,
  privilege: Privilege
}