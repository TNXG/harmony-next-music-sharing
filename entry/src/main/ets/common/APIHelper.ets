import { AccountProfile } from "../type/Account";
import { Privilege, Track , TrackAndPrivilege } from "../type/Playlist";
import Constant from "./Constant";
import Logger from "./Logger";
import { PreferencesUtil } from "./PreferenceUtil";

export function cover(url: string, size = 100) {
  return `${url}?param=${size}y${size}`
}

export function sample<T>(arr: Array<T>) {
  return arr[Math.floor(Math.random() * arr.length)];
}

export function shuffle<T>(arr: T[], count: number = arr.length): T[] {
  const shuffled = [...arr].sort(() => 0.5 - Math.random());
  return shuffled.slice(0, count);
}

export type QualityLevel = "standard" | "higher" | "exhigh" | "lossless" | "hires"

export const qualityLevels: QualityLevel[] =
  ["standard", "higher", "exhigh", "lossless", "hires"];

export const qualityBitrates: Record<QualityLevel, number> = {
  "standard": 128000,
  "higher": 192000,
  "exhigh": 320000,
  "lossless": 350000,
  "hires": 999000,
};

// 音质显示名称
export const qualityDescriptions: Record<QualityLevel, string> = {
  "standard": "标准 (128kbps)",
  "higher": "较高 (192kbps)",
  "exhigh": "极高 (320kbps)",
  "lossless": "无损",
  "hires": "Hi-Res",
};

export interface LevelList {
  level: QualityLevel;
  description: string;
  bitrate: number;
}

const unsupportedQuality = ["jyeffect","sky","dolby","jymaster"];

export function getSupportedQuality(songMaxQuality: QualityLevel, userQuality: QualityLevel): QualityLevel {

  Logger.info('CacheNextSong', `songMaxQuality: ${songMaxQuality}, userQuality: ${userQuality}`);

  const maxQuality = songMaxQuality.toString()
  // 如果不支持的音质等级，返回用户选择的
  if (unsupportedQuality.includes(maxQuality)) {
    return userQuality;
  }

  const songMaxIndex = qualityLevels.indexOf(songMaxQuality);
  const userQualityIndex = qualityLevels.indexOf(userQuality);

  if (songMaxIndex === -1) {
    return 'standard'; // 无效的最大音质时，默认返回标准音质
  }

  if (userQualityIndex <= songMaxIndex) {
    return userQuality;
  } else {
    return qualityLevels[songMaxIndex];
  }
}


// 根据音质等级返回码率
export function getQualityBitrate(quality: QualityLevel): number {
  return qualityBitrates[quality];
}


export function getQualityList(songMaxQuality: QualityLevel): LevelList[] {
  const songMaxIndex = qualityLevels.indexOf(songMaxQuality);

  if (songMaxIndex === -1) {
    // 无效的音质时返回所有可用音质
    return qualityLevels.map(level => ({
      level,
      description: qualityDescriptions[level],
      bitrate: qualityBitrates[level]
    } as LevelList));
  }

  return qualityLevels.slice(0, songMaxIndex + 1).map(level => ({
    level,
    description: qualityDescriptions[level],
    bitrate: qualityBitrates[level]
  } as LevelList));
}

interface PlayableResponse {
  reason: string;
  isPlayable: boolean;
  ignoreGray?: boolean;
}

let ignoreGray: boolean | null = null;

export function setIgnoreGray(value: boolean) {
  ignoreGray = value;
}

// 原版本保持不变
export function isTrackPlayable(trackWithPrivilege: TrackAndPrivilege): PlayableResponse {
  return isTrackPlayableWithParams(trackWithPrivilege.track, trackWithPrivilege.privilege);
}

const defaultPrivilege: Privilege = new Privilege();
defaultPrivilege.st = 0;

export function isTrackPlayableWithParams(track: Track, privilege: Privilege = defaultPrivilege): PlayableResponse {
  // 缓存 ignoreGray 的值
  if (ignoreGray === null) {
    ignoreGray = PreferencesUtil.get<boolean>('ignoreGray') || false;
  }

  const profile = PreferencesUtil.get<AccountProfile>("profile");
  const signAt = PreferencesUtil.get<number>('signAt');
  const isValidCookie = signAt &&
    (Date.now() - signAt) < Constant.COOKIE_EXPIRY_DAYS * 24 * 60 * 60 * 1000;

  const response: PlayableResponse = {
    isPlayable: true,
    reason: ''
  };

  if (ignoreGray) {
    response.ignoreGray = true;
    return response;
  }

  if (privilege?.pl > 0) {
    return response;
  }

  if (isValidCookie && profile && privilege?.cs) {
    return response;
  }

  if (track.fee === 1 || privilege?.fee === 1) {
    if (isValidCookie && profile?.vipType === 11) {
      response.isPlayable = true;
    } else {
      response.isPlayable = false;
      response.reason = 'VIP专属';
    }
    return response;
  }

  if (track.fee === 4 || privilege?.fee === 4) {
    response.isPlayable = false;
    response.reason = '付费专辑';
    return response;
  }

  if (track.noCopyrightRcmd !== null && track.noCopyrightRcmd !== undefined) {
    response.isPlayable = false;
    response.reason = '无版权';
    return response;
  }

  if (isValidCookie && profile && privilege?.st < 0) {
    response.isPlayable = false;
    response.reason = '已下架';
    return response;
  }

  return response;
}
