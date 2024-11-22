@Observed
export class Artist {
  id: number = 0;
  name: string = '';
  alias: string[] = [];
  tns: string[] = [];

  constructor(artist?: Artist) {
    if (artist !== undefined) {
      this.id = artist.id;
      this.name = artist.name;
      this.alias = artist.alias;
      this.tns = artist.tns;
    }
  }
}

@Observed
export class Album {
  id: number = 0;
  name: string = '';
  picUrl: string = '';
  tns: string[] = [];
  pic_str: string = '';
  pic: number = 0;

  constructor(album?: Album) {
    if (album !== undefined) {
      this.id = album.id;
      this.name = album.name;
      this.picUrl = album.picUrl;
      this.tns = album.tns;
      this.pic_str = album.pic_str;
      this.pic = album.pic;
    }
  }
}

@Observed
export class SongQuality {
  br: number = 0;
  fid: number = 0;
  size: number = 0;
  vd: number = 0;
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

@Observed
export class OriginSongArtist {
  id: number = 0;
  name: string = '';

  constructor(artist?: OriginSongArtist) {
    if (artist !== undefined) {
      this.id = artist.id;
      this.name = artist.name;
    }
  }
}

@Observed
export class OriginSongAlbum {
  id: number = 0;
  name: string = '';

  constructor(album?: OriginSongAlbum) {
    if (album !== undefined) {
      this.id = album.id;
      this.name = album.name;
    }
  }
}

@Observed
export class OriginSongData {
  songId: number = 0;
  name: string = '';
  artists: OriginSongArtist[] = [];
  albumMeta: OriginSongAlbum = new OriginSongAlbum();

  constructor(data?: OriginSongData) {
    if (data !== undefined) {
      this.songId = data.songId;
      this.name = data.name;
      this.artists = data.artists.map(artist => new OriginSongArtist(artist));
      this.albumMeta = new OriginSongAlbum(data.albumMeta);
    }
  }
}

@Observed
export class FreeTrialPrivilege {
  resConsumable: boolean = false;
  userConsumable: boolean = false;
  listenType: number | null = null;
  cannotListenReason: number | null = null;
  playReason: number | null = null;
  freeLimitTagType: number | null = null;

  constructor(privilege?: FreeTrialPrivilege) {
    if (privilege !== undefined) {
      this.resConsumable = privilege.resConsumable;
      this.userConsumable = privilege.userConsumable;
      this.listenType = privilege.listenType;
      this.cannotListenReason = privilege.cannotListenReason;
      this.playReason = privilege.playReason;
      this.freeLimitTagType = privilege.freeLimitTagType;
    }
  }
}

@Observed
export class ChargeInfo {
  rate: number = 0;
  chargeUrl: string | null = null;
  chargeMessage: string | null = null;
  chargeType: number = 0;

  constructor(info?: ChargeInfo) {
    if (info !== undefined) {
      this.rate = info.rate;
      this.chargeUrl = info.chargeUrl;
      this.chargeMessage = info.chargeMessage;
      this.chargeType = info.chargeType;
    }
  }
}

@Observed
export class Privilege {
  id: number = 0;
  // fee: number = 0;
  // payed: number = 0;
  st: number = 0;
  // pl: number = 0;
  // dl: number = 0;
  // sp: number = 0;
  // cp: number = 0;
  // subp: number = 0;
  // cs: boolean = false;
  // maxbr: number = 0;
  // fl: number = 0;
  // toast: boolean = false;
  // flag: number = 0;
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
  // chargeInfoList: ChargeInfo[] = [];

  constructor(privilege?: Privilege) {
    if (privilege !== undefined) {
      this.id = privilege.id;
      // this.fee = privilege.fee;
      // this.payed = privilege.payed;
      this.st = privilege.st;
      // this.pl = privilege.pl;
      // this.dl = privilege.dl;
      // this.sp = privilege.sp;
      // this.cp = privilege.cp;
      // this.subp = privilege.subp;
      // this.cs = privilege.cs;
      // this.maxbr = privilege.maxbr;
      // this.fl = privilege.fl;
      // this.toast = privilege.toast;
      // this.flag = privilege.flag;
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
      // this.chargeInfoList = privilege.chargeInfoList.map(info => new ChargeInfo(info));
    }
  }
}

@Observed
export class DailySong {
  // item: Artist | undefined;
  name: string = '';
  id: number = 0;
  ar: Artist[] = [];
  al: Album = new Album();
  // dt: number = 0;
  // h?: SongQuality;
  // m?: SongQuality;
  // l?: SongQuality;
  // sq?: SongQuality | null;
  // hr?: SongQuality | null;
  // reason?: string;
  tns?: string[];
  // recommendReason?: string;
  privilege?: Privilege;
  // originSongSimpleData?: OriginSongData;
  album?: Album;
  artists?: Artist;

  constructor(song?: DailySong) {
    if (song !== undefined) {
      // this.item = song.item ? new Artist(song.item) : undefined;
      this.name = song.name;
      this.id = song.id;
      this.ar = song.ar.map(artist => new Artist(artist));
      this.al = new Album(song.al);
      // this.dt = song.dt;
      // this.h = song.h ? new SongQuality(song.h) : undefined;
      // this.m = song.m ? new SongQuality(song.m) : undefined;
      // this.l = song.l ? new SongQuality(song.l) : undefined;
      // this.sq = song.sq ? new SongQuality(song.sq) : null;
      // this.hr = song.hr ? new SongQuality(song.hr) : null;
      // this.reason = song.reason;
      this.tns = song.tns;
      // this.recommendReason = song.recommendReason;
      this.privilege = song.privilege ? new Privilege(song.privilege) : undefined;
      // this.originSongSimpleData = song.originSongSimpleData ? new OriginSongData(song.originSongSimpleData) : undefined;
      this.album = song.album ? new Album(song.album) : undefined;
      this.artists = song.artists ? new Artist(song.artists) : undefined;
    }
  }
}

@Observed
export class NoCopyrightRcmd {
  type: number = 0;
  msg: string = '';
  songId: number = 0;

  constructor(rcmd?: NoCopyrightRcmd) {
    if (rcmd !== undefined) {
      this.type = rcmd.type;
      this.msg = rcmd.msg;
      this.songId = rcmd.songId;
    }
  }
}

@Observed
export class SongDetail extends DailySong {
  // pst?: number;
  // t?: number;
  // pop?: number;
  // st?: number;
  // rt?: string | null;
  // fee?: number;
  // v?: number;
  // crbt?: string | null;
  // cf?: string | null;
  // cd?: string | null;
  // no?: number;
  // rtUrl?: string | null;
  // rtUrls?: string[];
  // djId?: number;
  // copyright?: number;
  // s_id?: number;
  // mark?: number;
  // originCoverType?: number;
  // single?: number;
  // noCopyrightRcmd?: NoCopyrightRcmd | null;
  // mv?: number;
  // rtype?: number;
  // rurl?: string | null;
  // mst?: number;
  // cp?: number;
  // publishTime?: number;
  // alia?: string[];
  // resourceState?: boolean;
  // version?: number;
  // ftype?: number;

  constructor(detail?: SongDetail) {
    super(detail);
    // if (detail !== undefined) {
    //   this.pst = detail.pst;
    //   this.t = detail.t;
    //   this.pop = detail.pop;
    //   this.st = detail.st;
    //   this.rt = detail.rt;
    //   this.fee = detail.fee;
    //   this.v = detail.v;
    //   this.crbt = detail.crbt;
    //   this.cf = detail.cf;
    //   this.cd = detail.cd;
    //   this.no = detail.no;
    //   this.rtUrl = detail.rtUrl;
    //   this.rtUrls = detail.rtUrls;
    //   this.djId = detail.djId;
    //   this.copyright = detail.copyright;
    //   this.s_id = detail.s_id;
    //   this.mark = detail.mark;
    //   this.originCoverType = detail.originCoverType;
    //   this.single = detail.single;
    //   this.noCopyrightRcmd = detail.noCopyrightRcmd ? new NoCopyrightRcmd(detail.noCopyrightRcmd) : null;
    //   this.mv = detail.mv;
    //   this.rtype = detail.rtype;
    //   this.rurl = detail.rurl;
    //   this.mst = detail.mst;
    //   this.cp = detail.cp;
    //   this.publishTime = detail.publishTime;
    //   this.alia = detail.alia;
    //   this.resourceState = detail.resourceState;
    //   this.version = detail.version;
    //   this.ftype = detail.ftype;
    // }
  }
}

@Observed
export class FreeTrialInfoData {
  start: number = 0;
  end: number = 0;

  constructor(data?: FreeTrialInfoData) {
    if (data !== undefined) {
      this.start = data.start;
      this.end = data.end;
    }
  }
}

@Observed
export class SongUrl {
  id: number = 0;
  url: string = '';
  // br: number = 0;
  // size: number = 0;
  // md5: string = '';
  // code: number = 0;
  // expi: number = 0;
  // type: string = '';
  // gain: number = 0;
  // peak: number = 0;
  // fee: number = 0;
  // payed: number = 0;
  // flag: number = 0;
  // canExtend: boolean = false;
  // freeTrialInfo: FreeTrialInfoData | null = null;
  level: string = '';
  // encodeType: string = '';
  // freeTimeTrialPrivilege: FreeTrialPrivilege = new FreeTrialPrivilege();
  // urlSource: number = 0;

  constructor(songUrl?: SongUrl) {
    if (songUrl !== undefined) {
      this.id = songUrl.id;
      this.url = songUrl.url;
      // this.br = songUrl.br;
      // this.size = songUrl.size;
      // this.md5 = songUrl.md5;
      // this.code = songUrl.code;
      // this.expi = songUrl.expi;
      // this.type = songUrl.type;
      // this.gain = songUrl.gain;
      // this.peak = songUrl.peak;
      // this.fee = songUrl.fee;
      // this.payed = songUrl.payed;
      // this.flag = songUrl.flag;
      // this.canExtend = songUrl.canExtend;
      // this.freeTrialInfo = songUrl.freeTrialInfo ? new FreeTrialInfoData(songUrl.freeTrialInfo) : null;
      this.level = songUrl.level;
      // this.encodeType = songUrl.encodeType;
      // this.freeTimeTrialPrivilege = new FreeTrialPrivilege(songUrl.freeTimeTrialPrivilege);
      // this.urlSource = songUrl.urlSource;
    }
  }
}

@Observed
export class SongDetailResponse {
  songs: SongDetail[] = [];
  privileges: Privilege[] = [];
  code: number = 0;

  constructor(response?: SongDetailResponse) {
    if (response !== undefined) {
      this.songs = response.songs.map(song => new SongDetail(song));
      this.privileges = response.privileges.map(privilege => new Privilege(privilege));
      this.code = response.code;
    }
  }
}

@Observed
export class SongUrlResponse {
  data: SongUrl[] = []
  code: number = 0;

  constructor(response?: SongUrlResponse) {
    if (response !== undefined) {
      this.data = response.data.map(song => new SongUrl(song));
      this.code = response.code;
    }
  }
}

@Observed
export class SongCache {
  id: number | string = 0;
  name: string = '';
  level: string = '';
  path: string = '';
  coverImgUrl: string = '';
  artist: string[] = [];

  constructor(cache?: SongCache) {
    if (cache !== undefined) {
      this.id = cache.id;
      this.name = cache.name;
      this.level = cache.level;
      this.path = cache.path;
      this.coverImgUrl = cache.coverImgUrl;
      this.artist = cache.artist;
    }
  }
}

@Observed
export class LyricVersion {
  version: number = 0;
  lyric: string = '';

  constructor(version?: LyricVersion) {
    if (version !== undefined) {
      this.version = version.version;
      this.lyric = version.lyric;
    }
  }
}

@Observed
export class LyricResponse {
  sgc: boolean = false;
  sfy: boolean = false;
  qfy: boolean = false;
  lrc: LyricVersion = new LyricVersion();
  klyric: LyricVersion = new LyricVersion();
  tlyric: LyricVersion = new LyricVersion();
  romalrc: LyricVersion = new LyricVersion();
  code: number = 0;

  constructor(response?: LyricResponse) {
    if (response !== undefined) {
      this.sgc = response.sgc;
      this.sfy = response.sfy;
      this.qfy = response.qfy;
      this.lrc = new LyricVersion(response.lrc);
      this.klyric = new LyricVersion(response.klyric);
      this.tlyric = new LyricVersion(response.tlyric);
      this.romalrc = new LyricVersion(response.romalrc);
      this.code = response.code;
    }
  }
}

@Observed
export class LyricLine {
  time: number = 0;
  text: string = '';

  constructor(line?: LyricLine) {
    if (line !== undefined) {
      this.time = line.time;
      this.text = line.text;
    }
  }
}