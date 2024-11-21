@Observed
export class RelatedResource {
  icon?: string;
  title?: string;
  subTitle?: string;
  url?: string;
  resId?: string;
  resType?: string;

  constructor(resource?: RelatedResource) {
    if (resource !== undefined) {
      this.icon = resource.icon;
      this.title = resource.title;
      this.subTitle = resource.subTitle;
      this.url = resource.url;
      this.resId = resource.resId;
      this.resType = resource.resType;
    }
  }
}

@Observed
export class Artist {
  name: string = '';
  id: number = 0;
  // picId: number = 0;
  // img1v1Id: number = 0;
  // briefDesc: string = '';
  picUrl: string = '';
  // img1v1Url: string = '';
  // albumSize: number = 0;
  // alias: string[] = [];
  // trans: string = '';
  // musicSize: number = 0;
  // topicPerson: number = 0;
  // lastRank: number = 0;
  // score: number = 0;
  // picId_str?: string;
  // img1v1Id_str?: string;
  // transNames?: string[];
  // relatedRes: RelatedResource | null = null;

  constructor(artist?: Artist) {
    if (artist !== undefined) {
      this.name = artist.name;
      this.id = artist.id;
      // this.picId = artist.picId;
      // this.img1v1Id = artist.img1v1Id;
      // this.briefDesc = artist.briefDesc;
      this.picUrl = artist.picUrl;
      // this.img1v1Url = artist.img1v1Url;
      // this.albumSize = artist.albumSize;
      // this.alias = artist.alias;
      // this.trans = artist.trans;
      // this.musicSize = artist.musicSize;
      // this.topicPerson = artist.topicPerson;
      // this.lastRank = artist.lastRank;
      // this.score = artist.score;
      // this.picId_str = artist.picId_str;
      // this.img1v1Id_str = artist.img1v1Id_str;
      // this.transNames = artist.transNames;
      // this.relatedRes = artist.relatedRes ? new RelatedResource(artist.relatedRes) : null;
    }
  }
}

@Observed
export class ArtistList {
  artists: Artist[] = [];
  updateTime: number = 0;
  type: number = 0;

  constructor(list?: ArtistList) {
    if (list !== undefined) {
      this.artists = list.artists.map(artist => new Artist(artist));
      this.updateTime = list.updateTime;
      this.type = list.type;
    }
  }
}

@Observed
export class ArtistRankResponse {
  code: number = 0;
  list: ArtistList = new ArtistList();

  constructor(response?: ArtistRankResponse) {
    if (response !== undefined) {
      this.code = response.code;
      this.list = new ArtistList(response.list);
    }
  }
}

@Observed
export class Playlist {
  // subscribed: boolean | null = null;
  // creator: null = null;
  // artists: null = null;
  // tracks: null = null;
  updateFrequency: string = '';
  // backgroundCoverId: number = 0;
  // backgroundCoverUrl: string | null = null;
  // titleImage: number = 0;
  // coverText: string | null = null;
  // titleImageUrl: string | null = null;
  coverImageUrl: string | null = null;
  // iconImageUrl: string | null = null;
  // englishTitle: string | null = null;
  // opRecommend: boolean = false;
  // recommendInfo: null = null;
  // socialPlaylistCover: null = null;
  // tsSongCount: number = 0;
  // algType: null = null;
  // highQuality: boolean = false;
  // specialType: number = 0;
  // coverImgId: number = 0;
  // newImported: boolean = false;
  // anonimous: boolean = false;
  // updateTime: number = 0;
  // trackCount: number = 0;
  // commentThreadId: string = '';
  // trackUpdateTime: number = 0;
  coverImgUrl: string = '';
  // totalDuration: number = 0;
  // playCount: number = 0;
  // trackNumberUpdateTime: number = 0;
  // privacy: number = 0;
  // adType: number = 0;
  // subscribedCount: number = 0;
  // cloudTrackCount: number = 0;
  // createTime: number = 0;
  // ordered: boolean = false;
  // description: string | null = null;
  // status: number = 0;
  // tags: string[] = [];
  // userId: number = 0;
  name: string = '';
  id: number = 0;
  // coverImgId_str?: string;
  // ToplistType?: string;

  constructor(playlist?: Playlist) {
    if (playlist !== undefined) {
      // this.subscribed = playlist.subscribed;
      // this.creator = playlist.creator;
      // this.artists = playlist.artists;
      // this.tracks = playlist.tracks;
      this.updateFrequency = playlist.updateFrequency;
      // this.backgroundCoverId = playlist.backgroundCoverId;
      // this.backgroundCoverUrl = playlist.backgroundCoverUrl;
      // this.titleImage = playlist.titleImage;
      // this.coverText = playlist.coverText;
      // this.titleImageUrl = playlist.titleImageUrl;
      this.coverImageUrl = playlist.coverImageUrl;
      // this.iconImageUrl = playlist.iconImageUrl;
      // this.englishTitle = playlist.englishTitle;
      // this.opRecommend = playlist.opRecommend;
      // this.recommendInfo = playlist.recommendInfo;
      // this.socialPlaylistCover = playlist.socialPlaylistCover;
      // this.tsSongCount = playlist.tsSongCount;
      // this.algType = playlist.algType;
      // this.highQuality = playlist.highQuality;
      // this.specialType = playlist.specialType;
      // this.coverImgId = playlist.coverImgId;
      // this.newImported = playlist.newImported;
      // this.anonimous = playlist.anonimous;
      // this.updateTime = playlist.updateTime;
      // this.trackCount = playlist.trackCount;
      // this.commentThreadId = playlist.commentThreadId;
      // this.trackUpdateTime = playlist.trackUpdateTime;
      this.coverImgUrl = playlist.coverImgUrl;
      // this.totalDuration = playlist.totalDuration;
      // this.playCount = playlist.playCount;
      // this.trackNumberUpdateTime = playlist.trackNumberUpdateTime;
      // this.privacy = playlist.privacy;
      // this.adType = playlist.adType;
      // this.subscribedCount = playlist.subscribedCount;
      // this.cloudTrackCount = playlist.cloudTrackCount;
      // this.createTime = playlist.createTime;
      // this.ordered = playlist.ordered;
      // this.description = playlist.description;
      // this.status = playlist.status;
      // this.tags = playlist.tags;
      // this.userId = playlist.userId;
      this.name = playlist.name;
      this.id = playlist.id;
      // this.coverImgId_str = playlist.coverImgId_str;
      // this.ToplistType = playlist.ToplistType;
    }
  }
}

@Observed
export class ArtistToplist {
  coverUrl: string = '';
  name: string = '';
  updateFrequency: string = '';
  position: number = 0;
  upateFrequency: string = '';

  constructor(toplist?: ArtistToplist) {
    if (toplist !== undefined) {
      this.coverUrl = toplist.coverUrl;
      this.name = toplist.name;
      this.updateFrequency = toplist.updateFrequency;
      this.position = toplist.position;
      this.upateFrequency = toplist.upateFrequency;
    }
  }
}

@Observed
export class ToplistResponse {
  code: number = 0;
  list: Playlist[] = [];
  artistToplist: ArtistToplist = new ArtistToplist();

  constructor(response?: ToplistResponse) {
    if (response !== undefined) {
      this.code = response.code;
      this.list = response.list.map(playlist => new Playlist(playlist));
      this.artistToplist = new ArtistToplist(response.artistToplist);
    }
  }
}