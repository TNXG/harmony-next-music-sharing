import { picker } from '@kit.CoreFileKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';

interface AudioSaveResult {
  success: boolean;
  uri: string;
  error?: BusinessError;
  fileDescriptor?: number;
}

interface AudioSaveOptions {
  fileName?: string;
  content?: ArrayBuffer;
}

class AudioFileSaver {
  private static instance: AudioFileSaver;
  private context: common.Context | null;
  private lastSavedUri: string;
  private fileDescriptor: number;
  private initialized: boolean;

  private constructor() {
    this.context = null;
    this.lastSavedUri = '';
    this.fileDescriptor = -1;
    this.initialized = false;
  }

  /**
   * 获取AudioFileSaver单例
   * @returns AudioFileSaver实例
   */
  public static getInstance(): AudioFileSaver {
    if (!AudioFileSaver.instance) {
      AudioFileSaver.instance = new AudioFileSaver();
    }
    return AudioFileSaver.instance;
  }

  /**
   * 初始化AudioFileSaver
   * @param context UIAbilityContext
   * @throws Error 如果重复初始化
   */
  public init(context: common.Context): void {
    if (this.initialized) {
      throw new Error('AudioFileSaver has already been initialized');
    }
    this.context = context;
    this.initialized = true;
  }

  /**
   * 检查是否已初始化
   * @throws Error 如果未初始化
   */
  private checkInitialization(): void {
    if (!this.initialized || !this.context) {
      throw new Error('AudioFileSaver must be initialized with context before use');
    }
  }

  /**
   * 初始化保存选项
   * @param fileName 文件名
   * @returns picker.AudioSaveOptions
   */
  private createSaveOptions(fileName: string): picker.AudioSaveOptions {
    const audioSaveOptions = new picker.AudioSaveOptions();
    if (fileName) {
      audioSaveOptions.newFileNames = [fileName];
    }
    return audioSaveOptions;
  }

  /**
   * 打开文件获取文件描述符
   * @param uri 文件URI
   * @returns number 文件描述符
   */
  private openFile(uri: string): number {
    const file = fs.openSync(uri, fs.OpenMode.READ_WRITE);
    return file.fd;
  }

  /**
   * 写入文件内容
   * @param fd 文件描述符
   * @param content 写入内容
   * @returns number 写入的字节数
   */
  private writeFile(fd: number, content: ArrayBuffer): number {
    return fs.writeSync(fd, content);
  }

  /**
   * 关闭文件
   * @param fd 文件描述符
   */
  private closeFile(fd: number): void {
      fs.closeSync(fd);
  }

  /**
   * 保存音频文件
   * @param options 保存选项
   * @returns Promise<AudioSaveResult>
   */
  public async saveAudioFile(options: AudioSaveOptions): Promise<AudioSaveResult> {
    this.checkInitialization();

    const fileName = options.fileName || 'audio_' + Date.now() + '.mp3';
    const audioSaveOptions = this.createSaveOptions(fileName);
    const audioViewPicker = new picker.AudioViewPicker(this.context!);

    try {
      // 保存文件并获取URI
      const result = await audioViewPicker.save(audioSaveOptions);
      this.lastSavedUri = result[0];

      // 打开文件获取描述符
      this.fileDescriptor = this.openFile(this.lastSavedUri);

      // 如果有内容则写入
      if (options.content) {
        const writeLength = this.writeFile(this.fileDescriptor, options.content);
        console.info('Successfully wrote', writeLength, 'bytes to file');
      }

      // 关闭文件
      this.closeFile(this.fileDescriptor);

      return {
        success: true,
        uri: this.lastSavedUri,
        fileDescriptor: this.fileDescriptor
      };

    } catch (error) {
      console.error('Audio save operation failed:', error);
      return {
        success: false,
        uri: '',
        error: error as BusinessError
      };
    }
  }

  /**
   * 获取最后保存的文件URI
   * @returns string
   */
  public getLastSavedUri(): string {
    this.checkInitialization();
    return this.lastSavedUri;
  }

  /**
   * 获取当前文件描述符
   * @returns number
   */
  public getCurrentFileDescriptor(): number {
    this.checkInitialization();
    return this.fileDescriptor;
  }

  /**
   * 重置实例（主要用于测试）
   */
  public static resetInstance(): void {
    AudioFileSaver.instance = new AudioFileSaver();
  }
}


export const audioFileSaver = AudioFileSaver.getInstance()