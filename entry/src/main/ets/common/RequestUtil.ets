import axios, { AxiosResponse, AxiosError, InternalAxiosRequestConfig, AxiosHeaders } from "@ohos/axios";
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
  }
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

// 创建请求实例
const createAxiosInstance = (isAnonymous = false) => {
  const instance = axios.create({
    baseURL: PreferencesUtil.get<string>('customURL') || Constant.BASE_URL,
    timeout: Constant.DEFAULT_TIMEOUT,
  });

  // 添加通用拦截器
  instance.interceptors.request.use(requestInterceptors.addTimestamp);
  instance.interceptors.request.use(requestInterceptors.addRealIp);
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

// 创建实例
const request = createAxiosInstance();
const anonymous = createAxiosInstance(true);

// 添加更新baseURL的方法
export const updateBaseURL = (url?: string) => {
  const baseURL = url || Constant.BASE_URL;
  request.defaults.baseURL = baseURL;
  anonymous.defaults.baseURL = baseURL;
  Logger.info('RequestUtil', `BaseURL updated to: ${baseURL}`);
};

export { request, anonymous };
export default request;