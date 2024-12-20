import { Artist } from "./Toplist";
import { Type } from "@ohos.arkui.StateManagement";

/**
 * 专辑信息
 */
@Observed
export class Album {
  // paid: boolean = false;
  // onSale: boolean = false;
  // mark: number = 0;
  // awardTags: null = null;
  artists: Artist[] = [];
  // copyrightId: number = 0;
  // picId: number = 0;
  artist: Artist = new Artist();
  // publishTime: number = 0;
  // company: string = '';
  // briefDesc: string = '';
  picUrl: string = '';
  // commentThreadId: string = '';
  // blurPicUrl: string = '';
  // companyId: number = 0;
  // pic: number = 0;
  // status: number = 0;
  // subType: string = '';
  description: string = '';
  tags: string = '';
  alias: string[] = [];
  name: string = '';
  id: number = 0;
  // type: string = '';
  // size: number = 0;
  // picId_str: string = '';
  transNames?: string[];

  constructor(album?: Album) {
    if (album !== undefined) {
      // this.paid = album.paid;
      // this.onSale = album.onSale;
      // this.mark = album.mark;
      // this.awardTags = album.awardTags;
      this.artists = album.artists.map(artist => new Artist(artist));
      // this.copyrightId = album.copyrightId;
      // this.picId = album.picId;
      this.artist = new Artist(album.artist);
      // this.publishTime = album.publishTime;
      // this.company = album.company;
      // this.briefDesc = album.briefDesc;
      this.picUrl = album.picUrl;
      // this.commentThreadId = album.commentThreadId;
      // this.blurPicUrl = album.blurPicUrl;
      // this.companyId = album.companyId;
      // this.pic = album.pic;
      // this.status = album.status;
      // this.subType = album.subType;
      this.description = album.description;
      this.tags = album.tags;
      this.alias = album.alias;
      this.name = album.name;
      this.id = album.id;
      // this.type = album.type;
      // this.size = album.size;
      // this.picId_str = album.picId_str;
      this.transNames = album.transNames;
    }
  }
}

/**
 * 专辑列表响应
 */
@Observed
export class AlbumListResponse {
  total: number = 0;
  albums: Album[] = [];
  code: number = 0;

  constructor(response?: AlbumListResponse) {
    if (response !== undefined) {
      this.total = response.total;
      this.albums = response.albums.map(album => new Album(album));
      this.code = response.code;
    }
  }
}