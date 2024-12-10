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
@Observed
export class SongQuality {
  /** 比特率 */
  br: number = 0;

  /** 文件ID */
  fid: number = 0;

  /** 大小 */
  size: number = 0;

  /** 音量调节值 */
  vd: number = 0;

  /** 采样率 */
  sr: number = 0;

  constructor(quality?: SongQuality) {
    if (quality !== undefined) {
      this.br = quality.br;
      this.fid = quality.fid;
      this.size = quality.size;
      this.vd = quality.vd;
      this.sr = quality.sr;
    }
  }
}

/**
 * 试听权限
 */
@Observed
export class FreeTrialPrivilege {
  /** 是否可消费资源 */
  resConsumable: boolean = false;

  /** 是否可用户消费 */
  userConsumable: boolean = false;

  constructor(privilege?: FreeTrialPrivilege) {
    if (privilege) {
      this.resConsumable = privilege.resConsumable;
      this.userConsumable = privilege.userConsumable;
    }
  }
}

/**
 * 收费信息
 */
@Observed
export class ChargeInfo {
  /** 比特率 */
  rate: number = 0;

  constructor(info?: ChargeInfo) {
    if (info) {
      this.rate = info.rate;
    }
  }
}

/**
 * 歌曲播放权限
 */
@Observed
export class Privilege {
  id: number = 0;
  fee: number = 0;
  // payed: number = 0;
  // realPayed: number = 0;
  st: number = 0;
  pl: number = 0;
  // dl: number = 0;
  // sp: number = 0;
  // cp: number = 0;
  // subp: number = 0;
  cs: boolean = false;
  // maxbr: number = 0;
  // fl: number = 0;
  // toast: boolean = false;
  // flag: number = 0;
  // paidBigBang: boolean = false;
  // preSell: boolean = false;
  // playMaxbr: number = 0;
  // downloadMaxbr: number = 0;
  // maxBrLevel: string = '';
  // playMaxBrLevel: string = '';
  // downloadMaxBrLevel: string = '';
  // plLevel: string = '';
  dlLevel: string = '';
  // flLevel: string = '';
  // freeTrialPrivilege: FreeTrialPrivilege = new FreeTrialPrivilege();
  // rightSource: number = 0;
  // chargeInfoList: ChargeInfo[] = [];

  constructor(privilege?: Privilege) {
    if (privilege !== undefined) {
      this.id = privilege.id;
      this.fee = privilege.fee;
      // this.payed = privilege.payed;
      // this.realPayed = privilege.realPayed;
      this.st = privilege.st;
      this.pl = privilege.pl;
      // this.dl = privilege.dl;
      // this.sp = privilege.sp;
      // this.cp = privilege.cp;
      // this.subp = privilege.subp;
      this.cs = privilege.cs;
      // this.maxbr = privilege.maxbr;
      // this.fl = privilege.fl;
      // this.toast = privilege.toast;
      // this.flag = privilege.flag;
      // this.paidBigBang = privilege.paidBigBang;
      // this.preSell = privilege.preSell;
      // this.playMaxbr = privilege.playMaxbr;
      // this.downloadMaxbr = privilege.downloadMaxbr;
      // this.maxBrLevel = privilege.maxBrLevel;
      // this.playMaxBrLevel = privilege.playMaxBrLevel;
      // this.downloadMaxBrLevel = privilege.downloadMaxBrLevel;
      // this.plLevel = privilege.plLevel;
      this.dlLevel = privilege.dlLevel;
      // this.flLevel = privilege.flLevel;
      // this.freeTrialPrivilege = new FreeTrialPrivilege(privilege.freeTrialPrivilege);
      // this.rightSource = privilege.rightSource;
      // this.chargeInfoList = privilege.chargeInfoList.map(info => new ChargeInfo(info));
    }
  }
}

/**
 * 歌曲信息
 */
@Observed
export class Track {
  name: string = '';
  id: number = 0;
  // pst: number = 0;
  // t: number = 0;
  ar: Artist[] = [];
  alia: string[] = [];
  // pop: number = 0;
  // st: number = 0;
  // rt: string = '';
  fee: number = 0;
  // v: number = 0;
  // cf: string = '';
  al: Album = new Album();
  // dt: number = 0;
  // h: SongQuality = new SongQuality();
  // m: SongQuality = new SongQuality();
  // l: SongQuality = new SongQuality();
  // sq: SongQuality = new SongQuality();
  // hr: SongQuality | null = null;
  // cd: string = '';
  // no: number = 0;
  // ftype: number = 0;
  // djId: number = 0;
  // copyright: number = 0;
  // s_id: number = 0;
  // mark: number = 0;
  // originCoverType: number = 0;
  // resourceState: boolean = false;
  // version: number = 0;
  // single: number = 0;
  // mv: number = 0;
  // publishTime: number = 0;
  tns?: string[];
  noCopyrightRcmd? : null | object;

  constructor(track?: Track) {
    if (track !== undefined) {
      this.name = track.name;
      this.id = track.id;
      // this.pst = track.pst;
      // this.t = track.t;
      this.ar = track.ar.map(artist => new Artist(artist));
      this.alia = track.alia;
      // this.pop = track.pop;
      // this.st = track.st;
      // this.rt = track.rt;
      this.fee = track.fee;
      // this.v = track.v;
      // this.cf = track.cf;
      this.al = new Album(track.al);
      // this.dt = track.dt;
      // this.h = new SongQuality(track.h);
      // this.m = new SongQuality(track.m);
      // this.l = new SongQuality(track.l);
      // this.sq = new SongQuality(track.sq);
      // this.hr = track.hr ? new SongQuality(track.hr) : null;
      // this.cd = track.cd;
      // this.no = track.no;
      // this.ftype = track.ftype;
      // this.djId = track.djId;
      // this.copyright = track.copyright;
      // this.s_id = track.s_id;
      // this.mark = track.mark;
      // this.originCoverType = track.originCoverType;
      // this.resourceState = track.resourceState;
      // this.version = track.version;
      // this.single = track.single;
      // this.mv = track.mv;
      // this.publishTime = track.publishTime;
      this.tns = track.tns;
      this.noCopyrightRcmd = track?.noCopyrightRcmd;
    }
  }
}

/**
 * 歌曲ID对象
 */
@Observed
export class TrackId {
  id: number = 0;
  // v: number = 0;
  // t: number = 0;
  // at: number = 0;
  // uid: number = 0;
  // rcmdReason: string = '';
  // rcmdReasonTitle?: string;

  constructor(trackId?: TrackId) {
    if (trackId !== undefined) {
      this.id = trackId.id;
      // this.v = trackId.v;
      // this.t = trackId.t;
      // this.at = trackId.at;
      // this.uid = trackId.uid;
      // this.rcmdReason = trackId.rcmdReason;
      // this.rcmdReasonTitle = trackId.rcmdReasonTitle;
    }
  }
}

/**
 * 创建者信息
 */
@Observed
export class Creator {
  // defaultAvatar: boolean = false;
  // province: number = 0;
  // authStatus: number = 0;
  // followed: boolean = false;
  avatarUrl: string = '';
  // accountStatus: number = 0;
  // gender: number = 0;
  // city: number = 0;
  // birthday: number = 0;
  userId: number = 0;
  // userType: number = 0;
  nickname: string = '';
  // signature: string = '';
  // description: string = '';
  // detailDescription: string = '';
  // avatarImgId: number = 0;
  // backgroundImgId: number = 0;
  // backgroundUrl: string = '';
  // authority: number = 0;
  // mutual: boolean = false;
  // djStatus: number = 0;
  // vipType: number = 0;
  // authenticationTypes: number = 0;
  // avatarImgIdStr: string = '';
  // backgroundImgIdStr: string = '';
  // anchor: boolean = false;

  constructor(creator?: Creator) {
    if (creator !== undefined) {
      // this.defaultAvatar = creator.defaultAvatar;
      // this.province = creator.province;
      // this.authStatus = creator.authStatus;
      // this.followed = creator.followed;
      this.avatarUrl = creator.avatarUrl;
      // this.accountStatus = creator.accountStatus;
      // this.gender = creator.gender;
      // this.city = creator.city;
      // this.birthday = creator.birthday;
      this.userId = creator.userId;
      // this.userType = creator.userType;
      this.nickname = creator.nickname;
      // this.signature = creator.signature;
      // this.description = creator.description;
      // this.detailDescription = creator.detailDescription;
      // this.avatarImgId = creator.avatarImgId;
      // this.backgroundImgId = creator.backgroundImgId;
      // this.backgroundUrl = creator.backgroundUrl;
      // this.authority = creator.authority;
      // this.mutual = creator.mutual;
      // this.djStatus = creator.djStatus;
      // this.vipType = creator.vipType;
      // this.authenticationTypes = creator.authenticationTypes;
      // this.avatarImgIdStr = creator.avatarImgIdStr;
      // this.backgroundImgIdStr = creator.backgroundImgIdStr;
      // this.anchor = creator.anchor;
    }
  }
}

/**
 * 单个歌单信息
 */
@Observed
export class Playlist {
  // subscribed: boolean | null = null;
  creator: Creator = new Creator();
  artists: Artist[] | null = null;
  tracks: Track[] | null = null;
  trackIds: TrackId[] | null = null;
  // top: boolean = false;
  updateFrequency: string | null = null;
  // backgroundCoverId: number = 0;
  // backgroundCoverUrl: string | null = null;
  // titleImage: number = 0;
  // titleImageUrl: string | null = null;
  // englishTitle: string | null = null;
  // opRecommend: boolean = false;
  // subscribedCount: number = 0;
  // cloudTrackCount: number = 0;
  // userId: number = 0;
  // totalDuration: number = 0;
  // coverImgId: number = 0;
  // privacy: number = 0;
  // trackUpdateTime: number = 0;
  trackCount: number = 0;
  // updateTime: number = 0;
  // commentThreadId: string = '';
  coverImgUrl: string = '';
  // specialType: number = 0;
  // anonimous: boolean = false;
  // createTime: number = 0;
  // highQuality: boolean = false;
  // newImported: boolean = false;
  // trackNumberUpdateTime: number = 0;
  // playCount: number = 0;
  // adType: number = 0;
  // description: string | null = null;
  // tags: string[] = [];
  // ordered: boolean = false;
  // status: number = 0;
  name: string = '';
  id: number = 0;
  // coverImgId_str?: string;
  // copied: boolean = false;
  // containsTracks: boolean = false;
  // transNames?: string[];
  // hasBaseInfo?: boolean = false;

  constructor(playlist?: Playlist) {
    if (playlist !== undefined) {
      // this.subscribed = playlist.subscribed;
      this.creator = new Creator(playlist.creator);
      this.artists = playlist.artists ? playlist.artists.map(artist => new Artist(artist)) : null;
      this.tracks = playlist.tracks ? playlist.tracks.map(track => new Track(track)) : null;
      this.trackIds = playlist.trackIds ? playlist.trackIds.map(trackId => new TrackId(trackId)) : null;
      // this.top = playlist.top;
      this.updateFrequency = playlist.updateFrequency;
      // this.backgroundCoverId = playlist.backgroundCoverId;
      // this.backgroundCoverUrl = playlist.backgroundCoverUrl;
      // this.titleImage = playlist.titleImage;
      // this.titleImageUrl = playlist.titleImageUrl;
      // this.englishTitle = playlist.englishTitle;
      // this.opRecommend = playlist.opRecommend;
      // this.subscribedCount = playlist.subscribedCount;
      // this.cloudTrackCount = playlist.cloudTrackCount;
      // this.userId = playlist.userId;
      // this.totalDuration = playlist.totalDuration;
      // this.coverImgId = playlist.coverImgId;
      // this.privacy = playlist.privacy;
      // this.trackUpdateTime = playlist.trackUpdateTime;
      this.trackCount = playlist.trackCount;
      // this.updateTime = playlist.updateTime;
      // this.commentThreadId = playlist.commentThreadId;
      this.coverImgUrl = playlist.coverImgUrl;
      // this.specialType = playlist.specialType;
      // this.anonimous = playlist.anonimous;
      // this.createTime = playlist.createTime;
      // this.highQuality = playlist.highQuality;
      // this.newImported = playlist.newImported;
      // this.trackNumberUpdateTime = playlist.trackNumberUpdateTime;
      // this.playCount = playlist.playCount;
      // this.adType = playlist.adType;
      // this.description = playlist.description;
      // this.tags = playlist.tags;
      // this.ordered = playlist.ordered;
      // this.status = playlist.status;
      this.name = playlist.name;
      this.id = playlist.id;
      // this.coverImgId_str = playlist.coverImgId_str;
      // this.copied = playlist.copied;
      // this.containsTracks = playlist.containsTracks;
      // this.transNames = playlist.transNames;
      // this.hasBaseInfo = playlist.hasBaseInfo;
    }
  }
}

@Observed
export class PlaylistDetailResponse {
  code: number = 0;
  playlist: Playlist = new Playlist();
  privileges: Privilege[] = [];

  constructor(response?: PlaylistDetailResponse) {
    if (response !== undefined) {
      this.code = response.code;
      this.playlist = new Playlist(response.playlist);
      this.privileges = response.privileges.map(privilege => new Privilege(privilege));
    }
  }
}

@Observed
export class UserPlaylistResponse {
  more: boolean = false;
  playlist: Playlist[] = [];
  code: number = 0;

  constructor(response?: UserPlaylistResponse) {
    if (response !== undefined) {
      this.more = response.more;
      this.code = response.code;
      this.playlist = response.playlist.map(playlist => new Playlist(playlist));
    }
  }
}

@Observed
export class StatsResponse {
  commentCount: number = 0;
  shareCount: number = 0;
  playCount: number = 0;
  bookedCount: number = 0;
  subscribed: boolean = false;
  remarkName: string | null = null;
  followed: boolean = false;
  gradeStatus: string = '';
  code: number = 0;

  constructor(response?: StatsResponse) {
    if (response !== undefined) {
      this.commentCount = response.commentCount;
      this.shareCount = response.shareCount;
      this.playCount = response.playCount;
      this.bookedCount = response.bookedCount;
      this.subscribed = response.subscribed;
      this.remarkName = response.remarkName;
      this.followed = response.followed;
      this.gradeStatus = response.gradeStatus;
      this.code = response.code;
    }
  }
}

@Observed
export class TrackAndPrivilege {
  track: Track = new Track();
  privilege: Privilege = new Privilege();

  constructor(data?: TrackAndPrivilege) {
    if (data !== undefined) {
      this.track = new Track(data.track);
      this.privilege = new Privilege(data.privilege);
    }
  }
}