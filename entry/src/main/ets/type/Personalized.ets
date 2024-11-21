import { DailySong } from "./Song";

/**
 * 个性化推荐歌单项目
 * 用于描述每个推荐歌单的详细信息
 */
@Observed
export class PersonalizedPlaylist {
  id: number = 0;
  type: number = 0;
  name: string = '';
  copywriter: string = '';
  picUrl: string = '';
  canDislike: boolean = false;
  trackNumberUpdateTime: number = 0;
  playCount: number = 0;
  trackCount: number = 0;
  highQuality: boolean = false;
  alg: string = '';

  constructor(playlist?: PersonalizedPlaylist) {
    if (playlist !== undefined) {
      this.id = playlist.id;
      this.type = playlist.type;
      this.name = playlist.name;
      this.copywriter = playlist.copywriter;
      this.picUrl = playlist.picUrl;
      this.canDislike = playlist.canDislike;
      this.trackNumberUpdateTime = playlist.trackNumberUpdateTime;
      this.playCount = playlist.playCount;
      this.trackCount = playlist.trackCount;
      this.highQuality = playlist.highQuality;
      this.alg = playlist.alg;
    }
  }
}

/**
 * 个性化推荐
 * 包含推荐歌单列表及相关配置信息
 */
@Observed
export class Personalized {
  hasTaste: boolean = false;
  code: number = 0;
  category: number = 0;
  result: PersonalizedPlaylist[] = [];

  constructor(personalized?: Personalized) {
    if (personalized !== undefined) {
      this.hasTaste = personalized.hasTaste;
      this.code = personalized.code;
      this.category = personalized.category;
      this.result = personalized.result.map(playlist => new PersonalizedPlaylist(playlist));
    }
  }
}

@Observed
export class FMResponse {
  popAdjust: boolean = false;
  data: Array<DailySong> = [];
  tag: string | null = null;
  code: number = 0;

  constructor(response?: FMResponse) {
    if (response !== undefined) {
      this.popAdjust = response.popAdjust;
      this.data = response.data.map(song => new DailySong(song));
      this.tag = response.tag;
      this.code = response.code;
    }
  }
}