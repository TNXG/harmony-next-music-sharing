import axios from '@ohos/axios';
import { PreferencesUtil } from '../common/PreferenceUtil';

// 二维码生成接口响应类型
export interface QRKeyResponseData {
  url: string;
  qrcode_key: string;
}

export interface QRKeyResponse {
  code: number;
  message: string;
  ttl: number;
  data: QRKeyResponseData;
}

interface QrPollResponseData {
  url: string;
  refresh_token: string;
  timestamp: number;
  code: number;
  message: string;
}

interface QRPollResponse {
  code: number;
  message: string;
  ttl: number;
  data: QrPollResponseData;
}

export interface QRStatusType {
  WAITING: number;
  SCANNED: number;
  SUCCESS: number;
}

interface BilibiliUserLevelInfo {
  current_level: number;
  current_min: number;
  current_exp: number;
  next_exp: string;
}

interface BilibiliUserOfficial {
  role: number;
  title: string;
  desc: string;
  type: number;
}

interface BilibiliUserOfficialVerify {
  type: number;
  desc: string;
}

interface BilibiliUserPendant {
  pid: number;
  name: string;
  image: string;
  expire: number;
  image_enhance: string;
  image_enhance_frame: string;
  n_pid: number;
}

interface BilibiliUserVipLabel {
  path: string;
  text: string;
  label_theme: string;
  text_color: string;
  bg_style: number;
  bg_color: string;
  border_color: string;
  use_img_label: boolean;
  img_label_uri_hans: string;
  img_label_uri_hant: string;
  img_label_uri_hans_static: string;
  img_label_uri_hant_static: string;
}

interface BilibiliUserVipAvatarIcon {
  icon_type: number;
  icon_resource: Record<string, never>;
}

interface BilibiliUserVip {
  type: number;
  status: number;
  due_date: number;
  vip_pay_type: number;
  theme_type: number;
  label: BilibiliUserVipLabel;
  avatar_subscript: number;
  nickname_color: string;
  role: number;
  avatar_subscript_url: string;
  tv_vip_status: number;
  tv_vip_pay_type: number;
  tv_due_date: number;
  avatar_icon: BilibiliUserVipAvatarIcon;
}

interface BilibiliUserWallet {
  mid: number;
  bcoin_balance: number;
  coupon_balance: number;
  coupon_due_time: number;
}

interface BilibiliUserWbiImg {
  img_url: string;
  sub_url: string;
}

interface BilibiliUserData {
  isLogin: boolean;
  email_verified: number;
  face: string;
  face_nft: number;
  face_nft_type: number;
  level_info: BilibiliUserLevelInfo;
  mid: number;
  mobile_verified: number;
  money: number;
  moral: number;
  official: BilibiliUserOfficial;
  officialVerify: BilibiliUserOfficialVerify;
  pendant: BilibiliUserPendant;
  scores: number;
  uname: string;
  vipDueDate: number;
  vipStatus: number;
  vipType: number;
  vip_pay_type: number;
  vip_theme_type: number;
  vip_label: BilibiliUserVipLabel;
  vip_avatar_subscript: number;
  vip_nickname_color: string;
  vip: BilibiliUserVip;
  wallet: BilibiliUserWallet;
  has_shop: boolean;
  shop_url: string;
  answer_status: number;
  is_senior_member: number;
  wbi_img: BilibiliUserWbiImg;
  is_jury: boolean;
  name_render: null;
}

export interface BilibiliUserResponseData {
  code: number;
  message: string;
  ttl: number;
  data: BilibiliUserData;
}

export const QR_STATUS: QRStatusType = {
  WAITING: 86101, // 等待扫码
  SCANNED: 86090, // 已扫码，等待确认
  SUCCESS: 0       // 登录成功
};


// 默认的User-Agent
const DEFAULT_USER_AGENT =
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36 Edg/130.0.0.0';

export const generateQRCode = async (): Promise<QRKeyResponseData> => {
  const response: QRKeyResponse =
    (await axios.get('https://passport.bilibili.com/x/passport-login/web/qrcode/generate',
      { headers: { 'User-Agent': DEFAULT_USER_AGENT } })).data;
  return response.data;
};

export const pollQRStatus = async (qrcode_key: string): Promise<QrPollResponseData> => {
  const response: QRPollResponse =
    (await axios.get('https://passport.bilibili.com/x/passport-login/web/qrcode/poll', {
      params: { qrcode_key },
      headers: { 'User-Agent': DEFAULT_USER_AGENT }
    })).data;
  return response.data;
};

export const saveCookies = async (setCookiesUrl: string): Promise<void> => {
  try {
    const biliSESSDATA = getQueryString('SESSDATA', setCookiesUrl);
    const biliCookies = `SESSDATA=${biliSESSDATA}`;
    await PreferencesUtil.put('biliCookies', biliCookies);
    console.log('Cookies saved successfully');
  } catch (error) {
    console.error('Failed to save cookies:', error);
  }
};

export const getQueryString = (name: string, url: string): string => {
  const regex = /[?&]?([^=]+)=([^&]*)/g;
  const matches = url.matchAll(regex);
  for (const match of matches) {
    if (match[1] === name) {
      return match[2];
    }
  }
  return '';
}

export const getBiliUserInfo = async (cookies: string): Promise<BilibiliUserData> => {
  const response: BilibiliUserResponseData = (await axios.get('https://api.bilibili.com/x/web-interface/nav', {
    headers: { 'User-Agent': DEFAULT_USER_AGENT, Cookie: cookies }
  })).data;
  return response.data
}