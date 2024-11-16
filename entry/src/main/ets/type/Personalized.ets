import { DailySong } from "./Song";

/**
 * 个性化推荐歌单项目接口
 * 用于描述每个推荐歌单的详细信息
 */
export interface PersonalizedPlaylist {
  /** 歌单唯一标识ID */
  id: number;
  /**
   * 歌单类型
   * 0: 普通歌单
   */
  type: number;
  /** 歌单名称 */
  name: string;
  /** 歌单描述文案 */
  copywriter: string;
  /** 歌单封面图片URL */
  picUrl: string;
  /** 是否可以调整推荐（不喜欢） */
  canDislike: boolean;
  /** 歌单内容最后更新时间戳 */
  trackNumberUpdateTime: number;
  /** 播放次数 */
  playCount: number;
  /** 歌单内音乐数量 */
  trackCount: number;
  /** 是否为精品歌单 */
  highQuality: boolean;
  /**
   * 推荐算法类型
   * 例如：'byNewUserGroup_combine'、'cityLevel_combine' 等
   */
  alg: string;
}

/**
 * 个性化推荐接口
 * 包含推荐歌单列表及相关配置信息
 */
export interface Personalized {
  /** 是否已有个性化推荐的音乐品味 */
  hasTaste: boolean;
  /**
   * 接口状态码
   * 200: 表示成功
   */
  code: number;
  /**
   * 推荐类别
   * 0: 表示歌单推荐
   */
  category: number;
  /** 推荐歌单列表 */
  result: PersonalizedPlaylist[];
}

export interface FMResponse {
  popAdjust: boolean;
  data: Array<DailySong>;
  tag: string | null;
  code: number;
}