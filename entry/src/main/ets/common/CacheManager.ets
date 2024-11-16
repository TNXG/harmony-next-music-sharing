import { common } from '@kit.AbilityKit';
import { PreferencesUtil } from './PreferenceUtil';
import Logger from './Logger';
import { SongCache } from '../type/Song';

// 缓存配置接口
interface CacheConfig {
  prefix: string; // 缓存key的前缀
}

// 缓存统计信息接口
export interface CacheStats {
  count: number;
  oldestTime: number;
  newestTime: number;
}

// 缓存项的元数据接口
interface CacheItem<T> {
  value: T;
  createTime: number;
  lastAccessTime: number;
}

// 默认配置
const DEFAULT_CONFIG: CacheConfig = {
  prefix: 'cache_'
};

interface CacheInfo {
  key: string;
  data: CacheItem<SongCache>;
}

class CacheManager {
  private static instance: CacheManager | null = null;
  private context: common.UIAbilityContext | null = null;
  private config: CacheConfig;
  private initialized: boolean = false;

  private constructor() {
    this.config = DEFAULT_CONFIG;
  }

  public static getInstance(): CacheManager {
    if (CacheManager.instance === null) {
      CacheManager.instance = new CacheManager();
    }
    return CacheManager.instance;
  }

  // 手动实现配置合并
  private mergeConfig(defaultConfig: CacheConfig, userConfig: CacheConfig): CacheConfig {
    const result: CacheConfig = {
      prefix: userConfig.prefix !== undefined ? userConfig.prefix : defaultConfig.prefix
    };
    return result;
  }

  public initialize(context: common.UIAbilityContext, config?: CacheConfig): void {
    if (this.initialized) {
      Logger.warn('CacheManager already initialized');
      return;
    }

    this.context = context;
    this.config = this.mergeConfig(DEFAULT_CONFIG, config || {} as CacheConfig);
    PreferencesUtil.init(context);

    this.initialized = true;
    Logger.info('CacheManager initialized successfully');
  }

  private checkInitialized() {
    if (!this.initialized || !this.context) {
      throw new Error('CacheManager not initialized. Please call initialize() first.');
    }
  }

  private getFullKey(key: string): string {
    return this.config.prefix + key;
  }

  public async set(key: string, value: SongCache): Promise<boolean> {
    this.checkInitialized();
    try {
      const cacheItem: CacheItem<SongCache> = {
        value: value,
        createTime: Date.now(),
        lastAccessTime: Date.now()
      };

      PreferencesUtil.put(this.getFullKey(key), JSON.stringify(cacheItem));
      return true;
    } catch (error) {
      Logger.error('Failed to set cache:', error);
      return false;
    }
  }

  public get(key: string): SongCache | null {
    this.checkInitialized();
    try {
      const fullKey = this.getFullKey(key);
      const data = PreferencesUtil.get<string>(fullKey);

      if (!data) {
        return null;
      }

      const cacheItem: CacheItem<SongCache> = JSON.parse(data);

      // 更新访问时间
      cacheItem.lastAccessTime = Date.now();
      PreferencesUtil.put(fullKey, JSON.stringify(cacheItem));

      return cacheItem.value;
    } catch (error) {
      Logger.error('Failed to get cache:', error);
      return null;
    }
  }

  public has(key: string): boolean {
    this.checkInitialized();
    return PreferencesUtil.hasKey(this.getFullKey(key));
  }

  public remove(key: string): boolean {
    this.checkInitialized();
    try {
      PreferencesUtil.delete(this.getFullKey(key));
      return true;
    } catch (error) {
      Logger.error('Failed to remove cache:', error);
      return false;
    }
  }

  public clear(): boolean {
    this.checkInitialized();
    try {
      const allData = PreferencesUtil.getAll();
      if (!allData) return false;

      const keys = Object.keys(allData);
      for (let i = 0; i < keys.length; i++) {
        const key = keys[i];
        if (key.startsWith(this.config.prefix)) {
          PreferencesUtil.delete(key);
        }
      }

      return true;
    } catch (error) {
      Logger.error('Failed to clear cache:', error);
      return false;
    }
  }

  public getList(): Array<CacheInfo> {
    this.checkInitialized();
    const result: Array<CacheInfo> = [];

    try {
      const allData = PreferencesUtil.getAll();
      if (!allData) return result;

      const entries = Object.keys(allData);
      for (let i = 0; i < entries.length; i++) {
        const key = entries[i];
        if (key.startsWith(this.config.prefix)) {
          const shortKey = key.slice(this.config.prefix.length);
          const value = Object(allData)[key] as string;
          const cacheItem: CacheItem<SongCache> = JSON.parse(value);
          result.push({ key: shortKey, data: cacheItem });
        }
      }
    } catch (error) {
      Logger.error('Failed to get cache list:', error);
    }

    return result;
  }

  public getStats(): CacheStats {
    this.checkInitialized();
    let count = 0;
    let oldestTime = Date.now();
    let newestTime = 0;

    try {
      const allData = PreferencesUtil.getAll();
      if (!allData) {
        return { count: 0, oldestTime: 0, newestTime: 0 };
      }

      const entries = Object.keys(allData);
      for (let i = 0; i < entries.length; i++) {
        const key = entries[i];
        if (key.startsWith(this.config.prefix)) {
          count++;
          const value = Object(allData)[key] as string;
          const cacheItem: CacheItem<SongCache> = JSON.parse(value);

          if (cacheItem.createTime < oldestTime) {
            oldestTime = cacheItem.createTime;
          }
          if (cacheItem.lastAccessTime > newestTime) {
            newestTime = cacheItem.lastAccessTime;
          }
        }
      }
    } catch (error) {
      Logger.error('Failed to get cache stats:', error);
    }

    return {
      count: count,
      oldestTime: oldestTime,
      newestTime: newestTime
    };
  }

  public destroy() {
    this.initialized = false;
    this.context = null;
  }
}

const cacheManager = CacheManager.getInstance();
export { cacheManager, CacheManager };