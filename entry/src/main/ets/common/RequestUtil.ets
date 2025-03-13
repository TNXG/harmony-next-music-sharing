import axios, { AxiosResponse, AxiosError, InternalAxiosRequestConfig, AxiosInstance } from "@ohos/axios";
import Logger from './Logger';
import Constant from './Constant';
import { PreferencesUtil } from './PreferenceUtil';
import { PromptAction, promptAction, router } from "@kit.ArkUI";

const TAG = "RequestUtil";

// 类型定义
type RequestInterceptorFn = (config: InternalAxiosRequestConfig) => Promise<InternalAxiosRequestConfig> | InternalAxiosRequestConfig;
type ResponseInterceptorFn = (response: AxiosResponse) => AxiosResponse;
type ErrorHandlerFn = (error: AxiosError) => Promise<AxiosError>;

interface RequestInterceptors {
  setbiliCookies: RequestInterceptorFn;
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
  const chinaIPPrefixes = ['116.25', '116.76', '116.77', '116.78', '114.233', '211.161']

  const randomPrefix =
    chinaIPPrefixes[Math.floor(Math.random() * chinaIPPrefixes.length)]
  const randomSuffix = () => {
    return Math.floor(Math.random() * 255)
  }

  return `${randomPrefix}.${randomSuffix()}.${randomSuffix()}`
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


let isForceSetbiliCookies = false;

// 请求拦截器
const requestInterceptors: RequestInterceptors = {

  setbiliCookies: (config: InternalAxiosRequestConfig): InternalAxiosRequestConfig => {
    const biliCookies = PreferencesUtil.get<string>('biliCookies');
    // 如果没有自定义 URL，跳转设置页面，不发送请求
    if (!biliCookies && !isForceSetbiliCookies) {
      Logger.error(TAG, 'Custom URL not set');
      router.pushUrl({ url: 'pages/Setting' });

      promptAction.showToast({ message: '请先登录' });

      isForceSetbiliCookies = true;

      // 设置超时，避免重复跳转
      setTimeout(() => {
        isForceSetbiliCookies = false;
      }, 1000);
    }

    return config;
  },

  addTimestamp: (config: InternalAxiosRequestConfig): InternalAxiosRequestConfig => {
    return addUrlParameter(config, '_t', Date.now().toString());
  },

  addRealIp: (config: InternalAxiosRequestConfig): InternalAxiosRequestConfig => {
    let realIp = PreferencesUtil.get<string>('fakeIp');
    if (!realIp) {
      realIp = getRandomChinaIPv4();
      PreferencesUtil.put('fakeIp', realIp);
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
      if ((config.url && weapiUrls.some((url) => config.url?.includes(url))) ||
      PreferencesUtil.get<boolean>("forceWebApi")) {
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

const rawAxios = axios.create({
  timeout: Constant.DEFAULT_TIMEOUT
});

// 临时的强制刷新标志
let forceRefresh = false;

const createCacheAdapter = () => {
  // 需要缓存的 URL 列表
  const cacheUrls = [
    '/lyric',
    '/user/playlist',
    '/playlist/detail',
    '/personalized',
    '/toplist/artist',
    '/toplist',
    '/album/new'
  ];

  const buildCacheKey = (url: string): string => {
    // 移除 realIp 和时间戳参数 
    const key = url.replace(/[?&]realIp=[^&]*/, '')
      .replace(/[?&]_t=\d+/, '')
      .replace(/[?&]$/, ''); // 清理末尾可能剩余的 ? 或 &
    return key;
  };

  return async (config: InternalAxiosRequestConfig): Promise<AxiosResponse> => {
    // 删除适配器
    config.adapter = undefined;

    const baseUrl = config.url?.split('?')[0];
    if (!baseUrl || !cacheUrls.some(url => baseUrl.includes(url))) {
      return rawAxios(config);
    }

    const cacheKey = `url_${buildCacheKey(config.url || '')}`;

    // 如果不是强制刷新，尝试获取缓存
    if (!forceRefresh) {
      try {
        const cachedData = PreferencesUtil.get<string>(cacheKey);
        if (cachedData) {
          Logger.info(TAG, `Cache hit for ${cacheKey}`);
          return JSON.parse(cachedData);
        }
      } catch (error) {
        Logger.error(TAG, `Cache error for ${cacheKey}: ${error}`);
      }
    }

    // 发送请求并更新缓存
    Logger.info(TAG, forceRefresh ?
      `Force refresh for ${cacheKey}` :
      `Cache miss for ${cacheKey}`
    );

    rawAxios.defaults.adapter = undefined;
    const response: AxiosResponse = await rawAxios(config);

    try {
      PreferencesUtil.put(cacheKey, JSON.stringify(response));
    } catch (error) {
      Logger.error(TAG, `Failed to cache response for ${cacheKey}: ${error}`);
    }

    // 重置强制刷新标志
    setTimeout(() => {
      forceRefresh = false;
    }, 1000);

    return response;
  };
};

// 响应拦截器
const responseInterceptors: ResponseInterceptors = {
  handleResponse: (response: AxiosResponse): AxiosResponse => {
    const responseStr = JSON.stringify(response);
    // 分段打印日志，避免日志过长
    const maxLength = 2000;
    for (let i = 0; i < responseStr.length; i += maxLength) {
      Logger.info(TAG, responseStr.slice(i, i + maxLength));
    }
    return response;
  },

  handleError: (error: AxiosError): Promise<AxiosError> => {
    Logger.error(TAG, error.message);
    return Promise.reject(error);
  }
};

// 创建请求实例的函数
const createAxiosInstance = (isAnonymous = false): AxiosInstance => {
  Logger.info('RequestUtil', `biliCookies Using ${PreferencesUtil.get<string>('biliCookies')}`);
  const baseUrl = PreferencesUtil.get<string>('biliCookies');
  const instance = axios.create({
    baseURL: baseUrl,
    timeout: Constant.DEFAULT_TIMEOUT,
    adapter: createCacheAdapter()
  });

  // 添加通用拦截器
  instance.interceptors.request.use(requestInterceptors.setbiliCookies);
  instance.interceptors.request.use(requestInterceptors.addTimestamp);
  instance.interceptors.request.use(requestInterceptors.addRealIp);
  instance.interceptors.request.use(requestInterceptors.addCrypto);
  instance.interceptors.response.use(
    responseInterceptors.handleResponse,
    responseInterceptors.handleError
  );

  // 为非匿名实例添加认证拦截器
  if (!isAnonymous) {
    // instance.interceptors.request.use(requestInterceptors.refreshLogin);
    instance.interceptors.request.use(
      requestInterceptors.handleAuth,
      requestInterceptors.handleError
    );
  }

  return instance;
};

// 请求工具类
export class RequestUtil {
  private static instance: RequestUtil;
  private _request?: AxiosInstance;
  private _anonymous?: AxiosInstance;

  private constructor() {
  }

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

export const forceRefreshCache = (): void => {
  forceRefresh = true;
};

// 默认导出 getter 函数
export default getRequest;