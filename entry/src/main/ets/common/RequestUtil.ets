import axios, { AxiosResponse, AxiosError, InternalAxiosRequestConfig, AxiosInstance, AxiosHeaders } from "@ohos/axios";
import Logger from './Logger';
import Constant from './Constant';
import { PreferencesUtil } from './PreferenceUtil';

const TAG = "RequestUtil";

// 类型定义
type RequestInterceptorFn = (config: InternalAxiosRequestConfig) => Promise<InternalAxiosRequestConfig> | InternalAxiosRequestConfig;
type ResponseInterceptorFn = (response: AxiosResponse) => AxiosResponse;
type ErrorHandlerFn = (error: AxiosError) => Promise<AxiosError>;

interface RequestInterceptors {
  addTimestamp: RequestInterceptorFn;
  addRealIp: RequestInterceptorFn;
  handleAuth: RequestInterceptorFn;
  handleError: ErrorHandlerFn;
  addCrypto: RequestInterceptorFn;
}

interface ResponseInterceptors {
  handleResponse: ResponseInterceptorFn;
  handleError: ErrorHandlerFn;
}

// IP地址生成工具
const getRandomChinaIPv4 = (): string => {
  const CHINA_IP_RANGES = [
    [1, 8],
    [36, 63],
    [101, 127],
    [144, 159],
    [182, 223],
  ];

  const getRandomNumber = (min: number, max: number): number =>
  Math.floor(Math.random() * (max - min + 1)) + min;

  const range = CHINA_IP_RANGES[Math.floor(Math.random() * CHINA_IP_RANGES.length)];
  const octets = [
    getRandomNumber(range[0], range[1]),
    getRandomNumber(0, 255),
    getRandomNumber(0, 255),
    getRandomNumber(0, 255)
  ];

  return octets.join('.');
};

// 拦截器工具函数
const addUrlParameter =
  (config: InternalAxiosRequestConfig, param: string, value: string): InternalAxiosRequestConfig => {
    if (config.url) {
      const separator = config.url.includes('?') ? '&' : '?';
      config.url = `${config.url}${separator}${param}=${value}`;
    }
    return config;
  };

// 请求拦截器
const requestInterceptors: RequestInterceptors = {
  addTimestamp: (config: InternalAxiosRequestConfig): InternalAxiosRequestConfig => {
    return addUrlParameter(config, '_t', Date.now().toString());
  },

  addRealIp: (config: InternalAxiosRequestConfig): InternalAxiosRequestConfig => {
    let realIp = PreferencesUtil.get<string>('realIp');
    if (!realIp) {
      realIp = getRandomChinaIPv4();
      PreferencesUtil.put('realIp', realIp);
    }
    return addUrlParameter(config, 'realIp', realIp);
  },

  addCrypto: (config: InternalAxiosRequestConfig): InternalAxiosRequestConfig => {
    // weapi url 列表
    const weapiUrls = [
      '/playlist/subscribe',
      '/playlist/create'
    ];

    if (config.method?.toUpperCase() === 'POST') {
      if (!config.data) {
        config.data = {};
      }
      if ((config.url && weapiUrls.some((url) => config.url?.includes(url))) || PreferencesUtil.get<boolean>("forceWebApi")) {
        Logger.info('RequestUtil', `Crypto Using weapi`);
        config.data.crypto = "weapi"
      } else if (typeof config.data === 'object') {
        Logger.info('RequestUtil', `Crypto Using eapi`);
        config.data.crypto = "eapi";
      }
    }
    return config;
  },

  handleAuth: async (config: InternalAxiosRequestConfig): Promise<InternalAxiosRequestConfig> => {
    Logger.info(TAG, JSON.stringify(config));

    if (PreferencesUtil.isInitialized()) {
      const cookie = PreferencesUtil.get<string>('cookie');
      const signAt = PreferencesUtil.get<number>('signAt');
      const isValidCookie = cookie && signAt &&
        (Date.now() - signAt) < Constant.COOKIE_EXPIRY_DAYS * 24 * 60 * 60 * 1000;

      if (isValidCookie && config.method?.toUpperCase() === 'POST') {
        if (!config.data) {
          config.data = {};
        }
        config.data.cookie = cookie;
      }
    }
    return config;
  },

  handleError: (error: AxiosError): Promise<AxiosError> => {
    Logger.error(TAG, error.message);
    return Promise.reject(error);
  },
};

// 响应拦截器
const responseInterceptors: ResponseInterceptors = {
  handleResponse: (response: AxiosResponse): AxiosResponse => {
    Logger.info(TAG, JSON.stringify(response));
    return response;
  },

  handleError: (error: AxiosError): Promise<AxiosError> => {
    Logger.error(TAG, error.message);
    return Promise.reject(error);
  }
};

// 创建请求实例的函数
const createAxiosInstance = (isAnonymous = false): AxiosInstance => {
  Logger.info('RequestUtil', `CustomURL Using ${PreferencesUtil.get<string>('customURL')}`);
  const baseUrl =  PreferencesUtil.get<string>('customURL') || Constant.BASE_URL
  const instance = axios.create({
    baseURL: baseUrl,
    timeout: Constant.DEFAULT_TIMEOUT,
  });

  // 添加通用拦截器
  instance.interceptors.request.use(requestInterceptors.addTimestamp);
  instance.interceptors.request.use(requestInterceptors.addRealIp);
  instance.interceptors.request.use(requestInterceptors.addCrypto);
  instance.interceptors.response.use(
    responseInterceptors.handleResponse,
    responseInterceptors.handleError
  );

  // 为非匿名实例添加认证拦截器
  if (!isAnonymous) {
    instance.interceptors.request.use(
      requestInterceptors.handleAuth,
      requestInterceptors.handleError
    );
  }

  return instance;
};

// 请求工具类
// 请求工具类
export class RequestUtil {
  private static instance: RequestUtil;
  private _request?: AxiosInstance;
  private _anonymous?: AxiosInstance;

  private constructor() {}

  static getInstance(): RequestUtil {
    if (!RequestUtil.instance) {
      RequestUtil.instance = new RequestUtil();
    }
    return RequestUtil.instance;
  }

  getRequest(): AxiosInstance {
    if (!this._request) {
      this._request = createAxiosInstance();
    }
    return this._request;
  }

  getAnonymous(): AxiosInstance {
    if (!this._anonymous) {
      this._anonymous = createAxiosInstance(true);
    }
    return this._anonymous;
  }

  updateBaseURL(url?: string): void {
    const baseURL = url || Constant.BASE_URL;
    if (this._request) {
      this._request.defaults.baseURL = baseURL;
    }
    if (this._anonymous) {
      this._anonymous.defaults.baseURL = baseURL;
    }
    Logger.info(TAG, `BaseURL updated to: ${baseURL}`);
  }
}

// 导出获取实例的方法而不是实例本身
export const getRequest = (): AxiosInstance => RequestUtil.getInstance().getRequest();
export const getAnonymous = (): AxiosInstance => RequestUtil.getInstance().getAnonymous();
export const updateBaseURL = (url?: string): void => RequestUtil.getInstance().updateBaseURL(url);

// 默认导出 getter 函数
export default getRequest;