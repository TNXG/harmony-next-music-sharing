// 歌手信息
export interface Artist {
  id: number;
  name: string;
  alias: string[];
  tns: string[];
}

// 专辑信息
interface Album {
  id: number;
  name: string;
  picUrl: string;
  tns: string[];
  pic_str: string;
  pic: number;
}

// 音质信息
interface SongQuality {
  br: number;
  fid: number;
  size: number;
  vd: number;
  sr: number;
}

// 原创歌曲信息
interface OriginSongArtist {
  id: number;
  name: string;
}

interface OriginSongAlbum {
  id: number;
  name: string;
}

interface OriginSongData {
  songId: number;
  name: string;
  artists: OriginSongArtist[];
  albumMeta: OriginSongAlbum;
}

// 试听权限信息
interface FreeTrialPrivilege {
  resConsumable: boolean;
  userConsumable: boolean;
  listenType: number | null;
  cannotListenReason: number | null;
  playReason: number | null;
  freeLimitTagType: number | null;
}

// 收费信息
interface ChargeInfo {
  rate: number;
  chargeUrl: string | null;
  chargeMessage: string | null;
  chargeType: number;
}

// 权限信息
export interface Privilege {
  id: number;
  fee: number;
  payed: number;
  st: number;
  pl: number;
  dl: number;
  sp: number;
  cp: number;
  subp: number;
  cs: boolean;
  maxbr: number;
  fl: number;
  toast: boolean;
  flag: number;
  preSell: boolean;
  playMaxbr: number;
  downloadMaxbr: number;
  maxBrLevel: string;
  playMaxBrLevel: string;
  downloadMaxBrLevel: string;
  plLevel: string;
  dlLevel: string;
  flLevel: string;
  freeTrialPrivilege: FreeTrialPrivilege;
  chargeInfoList: ChargeInfo[];
}

// 推荐歌曲信息
export interface DailySong {
  item: Artist | undefined;
  name: string;
  id: number;
  ar: Artist[];
  al: Album;
  dt: number; // 歌曲时长
  h?: SongQuality; // 高品质
  m?: SongQuality; // 中品质
  l?: SongQuality; // 低品质
  sq?: SongQuality | null; // 无损品质
  hr?: SongQuality | null; // Hi-Res品质
  reason?: string; // 推荐原因
  tns?: string[]; // 译名
  recommendReason?: string;
  privilege?: Privilege;
  originSongSimpleData?: OriginSongData;

  // 兼容FM
  album?: Album;
  artists?: Artist
}

// 歌曲详情接口
interface NoCopyrightRcmd {
  type: number;
  msg: string;
  songId: number;
}

export interface SongDetail extends Omit<DailySong, 'reason' | 'recommendReason'> {
  pst?: number;
  t?: number;
  pop?: number;
  st?: number;
  rt?: string | null;
  fee?: number;
  v?: number;
  crbt?: string | null;
  cf?: string | null;
  cd?: string | null;
  no?: number;
  rtUrl?: string | null;
  rtUrls?: string[];
  djId?: number;
  copyright?: number;
  s_id?: number;
  mark?: number;
  originCoverType?: number;
  single?: number;
  noCopyrightRcmd?: NoCopyrightRcmd | null;
  mv?: number;
  rtype?: number;
  rurl?: string | null;
  mst?: number;
  cp?: number;
  publishTime?: number;

  // 兼容Track类型转换
  /** 别名列表 */
  alia?: string[];

  /** 资源状态 */
  resourceState?: boolean;

  /** 版本号 */
  version?: number;

  /** 文件类型 */
  ftype?: number;
}


// 音乐URL接口
interface FreeTrialInfoData {
  start: number; // 试听片段开始时间
  end: number; // 试听片段结束时间
}

export interface SongUrl {
  id: number;
  url: string;
  br: number; // 比特率
  size: number;
  md5: string;
  code: number;
  expi: number;
  type: string;
  gain: number;
  peak: number;
  fee: number;
  payed: number;
  flag: number;
  canExtend: boolean;
  freeTrialInfo: FreeTrialInfoData | null;
  level: string;
  encodeType: string;
  freeTimeTrialPrivilege: FreeTrialPrivilege;
  urlSource: number;
}

export interface SongDetailResponse {
  songs: SongDetail[];
  privileges: Privilege[];
  code: number;
}

export interface SongUrlResponse {
  data: SongUrl[];
  code: number;
}

export interface SongCache {
  id: number | string // 歌曲id
  name: string // 歌曲名称
  level: string // 歌曲音质等级
  path: string // 存储路径
  coverImgUrl: string // 歌曲封面
  artist: string[] // 艺术家
}