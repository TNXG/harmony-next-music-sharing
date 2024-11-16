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

export type QualityLevel = "standard" | "higher" | "exhigh" | "lossless" | "hires" | "jyeffect" | "sky" | "dolby"
  | "jymaster";

const qualityLevels: QualityLevel[] =
  ["standard", "higher", "exhigh", "lossless", "hires", "jyeffect", "sky", "dolby", "jymaster"];

export function getSupportedQuality(songMaxQuality: QualityLevel, userQuality: QualityLevel): QualityLevel {
  const songMaxIndex = qualityLevels.indexOf(songMaxQuality);
  const userQualityIndex = qualityLevels.indexOf(userQuality);

  if (userQualityIndex === -1 || songMaxIndex === -1) {
    return userQuality;
  }

  if (userQualityIndex <= songMaxIndex) {
    return userQuality;
  } else {
    return qualityLevels[songMaxIndex];
  }
}

export interface LevelType {
  "standard": string;
  "higher": string;
  "exhigh": string;
  "lossless": string;
  "hires": string;
  "jyeffect": string;
  "sky": string;
  "dolby": string;
  "jymaster": string;
}

export const qualityDescriptions: LevelType = {
  "standard": "标准",
  "higher": "较高",
  "exhigh": "极高",
  "lossless": "无损",
  "hires": "Hi-Res",
  "jyeffect": "高清环绕声",
  "sky": "沉浸环绕声",
  "dolby": "杜比全景声",
  "jymaster": "超清母带"
};

export interface LevelList {
  level: QualityLevel;
  description: string;
}

export function getQualityList(songMaxQuality: QualityLevel): LevelList[] {
  const songMaxIndex = qualityLevels.indexOf(songMaxQuality);

  if (songMaxIndex === -1) {
    throw new Error("Invalid quality level provided.");
  }

  return qualityLevels.slice(0, songMaxIndex + 1).map(level => ({
    level,
    description: Object(qualityDescriptions)[level]
  } as LevelList));
}
