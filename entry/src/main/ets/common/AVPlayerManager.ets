import { media } from '@kit.MediaKit';
import { avSession } from '@kit.AVSessionKit';
import { audio } from '@kit.AudioKit';
import { common } from '@kit.AbilityKit';
import Logger from './Logger';
import { globalPlaylist, PlayMode } from './GlobalPlayListManager';
import { fileIo as fs } from '@kit.CoreFileKit';
import { EventBus } from './EventBus';

// 定义回调函数的类型
export interface PlayerCallbacks {
  onPlay: Array<() => void>;
  onPause: Array<() => void>;
  onStop: Array<() => void>;
  onSeek: Array<(position: number) => void>;
  onStateChange: Array<(state: string) => void>;
  onError: Array<(error: Error) => void>;
  onCompleted: Array<() => void>;
  onAudioInterrupt: Array<(info: audio.InterruptEvent) => void>;
  onBufferingUpdate: Array<(progress: number) => void>;
  onDurationChange: Array<(duration: number) => void>;
}

class AVPlayerManager {
  private avPlayer: media.AVPlayer | null = null;
  private avSession: avSession.AVSession | null = null;
  private currentPlaybackState: avSession.PlaybackState = avSession.PlaybackState.PLAYBACK_STATE_PAUSE;
  private context: common.UIAbilityContext | undefined;

  private formCached = false // 如果从缓存中打开
  // 初始化所有回调为空数组
  private callbacks: PlayerCallbacks = {
    onPlay: [],
    onPause: [],
    onStop: [],
    onSeek: [],
    onStateChange: [],
    onError: [],
    onCompleted: [],
    onAudioInterrupt: [],
    onBufferingUpdate: [],
    onDurationChange: []
  };
  private isPlayingBeforeInterrupt: boolean = false;

  public async init(context: common.UIAbilityContext) {
    this.context = context;
    await this.initAVSession();
  }

  // 添加回调监听
  public addListener(type: keyof PlayerCallbacks, callback: Function) {
    switch (type) {
      case 'onPlay':
        this.callbacks.onPlay.push(callback as () => void);
        break;
      case 'onPause':
        this.callbacks.onPause.push(callback as () => void);
        break;
      case 'onStop':
        this.callbacks.onStop.push(callback as () => void);
        break;
      case 'onSeek':
        this.callbacks.onSeek.push(callback as (position: number) => void);
        break;
      case 'onStateChange':
        this.callbacks.onStateChange.push(callback as (state: string) => void);
        break;
      case 'onError':
        this.callbacks.onError.push(callback as (error: Error) => void);
        break;
      case 'onCompleted':
        this.callbacks.onCompleted.push(callback as () => void);
        break;
      case 'onAudioInterrupt':
        this.callbacks.onAudioInterrupt.push(callback as (info: audio.InterruptEvent) => void);
        break;
      case 'onBufferingUpdate':
        this.callbacks.onBufferingUpdate.push(callback as (progress: number) => void);
        break;
      case 'onDurationChange':
        this.callbacks.onDurationChange.push(callback as (duration: number) => void);
        break;
    }
  }

  // 移除特定回调监听
  public removeListener(type: keyof PlayerCallbacks, callback: Function) {
    switch (type) {
      case 'onPlay':
        this.callbacks.onPlay = this.callbacks.onPlay.filter(cb => cb !== callback);
        break;
      case 'onPause':
        this.callbacks.onPause = this.callbacks.onPause.filter(cb => cb !== callback);
        break;
      case 'onStop':
        this.callbacks.onStop = this.callbacks.onStop.filter(cb => cb !== callback);
        break;
      case 'onSeek':
        this.callbacks.onSeek = this.callbacks.onSeek.filter(cb => cb !== callback);
        break;
      case 'onStateChange':
        this.callbacks.onStateChange = this.callbacks.onStateChange.filter(cb => cb !== callback);
        break;
      case 'onError':
        this.callbacks.onError = this.callbacks.onError.filter(cb => cb !== callback);
        break;
      case 'onCompleted':
        this.callbacks.onCompleted = this.callbacks.onCompleted.filter(cb => cb !== callback);
        break;
      case 'onAudioInterrupt':
        this.callbacks.onAudioInterrupt = this.callbacks.onAudioInterrupt.filter(cb => cb !== callback);
        break;
      case 'onBufferingUpdate':
        this.callbacks.onBufferingUpdate = this.callbacks.onBufferingUpdate.filter(cb => cb !== callback);
        break;
      case 'onDurationChange':
        this.callbacks.onDurationChange = this.callbacks.onDurationChange.filter(cb => cb !== callback);
        break;
    }
  }

  // 清除指定回调监听
  public clearListener(type: keyof PlayerCallbacks) {
    switch (type) {
      case 'onPlay':
        this.callbacks.onPlay = [];
        break;
      case 'onPause':
        this.callbacks.onPause = [];
        break;
      case 'onStop':
        this.callbacks.onStop = [];
        break;
      case 'onSeek':
        this.callbacks.onSeek = [];
        break;
      case 'onStateChange':
        this.callbacks.onStateChange = [];
        break;
      case 'onError':
        this.callbacks.onError = [];
        break;
      case 'onCompleted':
        this.callbacks.onCompleted = [];
        break;
      case 'onAudioInterrupt':
        this.callbacks.onAudioInterrupt = [];
        break;
      case 'onBufferingUpdate':
        this.callbacks.onBufferingUpdate = [];
        break;
      case 'onDurationChange':
        this.callbacks.onDurationChange = [];
        break;
    }
  }

  // 清除所有回调
  public clearCallbacks() {
    this.callbacks = {
      onPlay: [],
      onPause: [],
      onStop: [],
      onSeek: [],
      onStateChange: [],
      onError: [],
      onCompleted: [],
      onAudioInterrupt: [],
      onBufferingUpdate: [],
      onDurationChange: []
    };
  }

  private triggerPlay() {
    const callbacks = this.callbacks.onPlay;
    callbacks.forEach(callback => {
      callback();
    });
  }

  private triggerPause() {
    const callbacks = this.callbacks.onPause;
    callbacks.forEach(callback => {
      callback();
    });
  }

  private triggerStop() {
    const callbacks = this.callbacks.onStop;
    callbacks.forEach(callback => {
      callback();
    });
  }

  private triggerSeek(position: number) {
    const callbacks = this.callbacks.onSeek;
    callbacks.forEach(callback => {
      callback(position);
    });
  }

  private triggerStateChange(state: string) {
    const callbacks = this.callbacks.onStateChange;
    callbacks.forEach(callback => {
      callback(state);
    });
  }

  private triggerError(error: Error) {
    const callbacks = this.callbacks.onError;
    callbacks.forEach(callback => {
      callback(error);
    });
  }

  private triggerCompleted() {
    const callbacks = this.callbacks.onCompleted;
    callbacks.forEach(callback => {
      callback();
    });
  }

  private triggerAudioInterrupt(info: audio.InterruptEvent) {
    const callbacks = this.callbacks.onAudioInterrupt;
    callbacks.forEach(callback => {
      callback(info);
    });
  }

  private triggerBufferingUpdate(progress: number) {
    const callbacks = this.callbacks.onBufferingUpdate;
    callbacks.forEach(callback => {
      callback(progress);
    });
  }

  private triggerDurationChange(duration: number) {
    const callbacks = this.callbacks.onDurationChange;
    callbacks.forEach(callback => {
      callback(duration);
    });
  }

  private async initAVSession() {
    try {
      this.avSession = await avSession.createAVSession(this.context!, 'AudioPlayer', 'audio');
      await this.avSession.activate();
      await this.updatePlaybackState(this.currentPlaybackState);
      this.setupMediaSessionListeners();
    } catch (error) {
      Logger.error('Failed to initialize AVSession:', error.message);
      this.triggerError(error);
    }
  }

  private setupMediaSessionListeners() {
    if (!this.avSession) {
      return;
    }

    this.avSession.on('play', () => {
      this.play();
    });

    this.avSession.on('pause', () => {
      this.pause();
    });

    this.avSession.on('stop', () => {
      this.stop();
    });

    this.avSession.on('seek', (position: number) => {
      if (this.avPlayer) {
        this.avPlayer.seek(position);
        this.updatePlaybackState(this.currentPlaybackState, position);
        this.triggerSeek(position);
      }
    });

    this.avSession.on('playNext', () => {
      globalPlaylist.playNext();
    })

    this.avSession.on('playPrevious', () => {
      globalPlaylist.playPrevious()
    })

    this.avSession.on('setLoopMode', (mode) => {
      globalPlaylist.switchPlayMode()
    })

    this.avSession.on('toggleFavorite', () => {
      EventBus.send("ToggleFavorite")
    })
  }

  public async updatePlaybackState(state?: avSession.PlaybackState, position?: number) {
    if (!this.avSession) {
      return;
    }
    if (!state) {
      state = this.currentPlaybackState;
    }

    const getMode = (playMode: PlayMode) => {
      let mode = avSession.LoopMode.LOOP_MODE_SEQUENCE
      switch (playMode) {
        case PlayMode.SEQUENCE:
          mode = avSession.LoopMode.LOOP_MODE_SEQUENCE
          break;
        case PlayMode.RANDOM:
          mode = avSession.LoopMode.LOOP_MODE_SHUFFLE
          break;
        case PlayMode.LOOP:
          mode = avSession.LoopMode.LOOP_MODE_LIST
          break;
        case PlayMode.SINGLE:
          mode = avSession.LoopMode.LOOP_MODE_SINGLE
          break;
      }
      return mode
    }

    const playbackState: avSession.AVPlaybackState = {
      state: state === avSession.PlaybackState.PLAYBACK_STATE_PLAY ?
      avSession.PlaybackState.PLAYBACK_STATE_PLAY :
      avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
      position: {
        elapsedTime: position ?? this.avPlayer?.currentTime ?? 0,
        updateTime: new Date().getTime()
      },
      speed: 1.0,
      loopMode: getMode(globalPlaylist.getPlayMode())
    };
    await this.avSession.setAVPlaybackState(playbackState);
  }

  public getSession() {
    return this.avSession;
  }

  private setupAudioInterrupt(player: media.AVPlayer) {
    // 设置焦点模式为共享模式
    player.audioInterruptMode = audio.InterruptMode.SHARE_MODE;

    // 设置音频类型
    const audioRendererInfo: audio.AudioRendererInfo = {
      usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
      rendererFlags: 0
    };
    player.audioRendererInfo = audioRendererInfo;

    player.on('audioOutputDeviceChangeWithInfo', async (info: audio.AudioStreamDeviceChangeInfo) => {
      switch (info.changeReason) {
        case audio.AudioStreamDeviceChangeReason.REASON_OLD_DEVICE_UNAVAILABLE:
          // 设备不可用(如蓝牙断开)，需要暂停播放
          await this.pause()
          break;

        case audio.AudioStreamDeviceChangeReason.REASON_NEW_DEVICE_AVAILABLE:
          // 新设备可用
          break;

        case audio.AudioStreamDeviceChangeReason.REASON_OVERRODE:
          // 设备被切换
          break;
      }
    })

    // 设置音频打断监听
    player.on('audioInterrupt', async (interruptEvent: audio.InterruptEvent) => {
      this.triggerAudioInterrupt(interruptEvent);
      Logger.info("audioInterrupt", JSON.stringify(interruptEvent))
      if (interruptEvent.forceType === audio.InterruptForceType.INTERRUPT_FORCE) {
        switch (interruptEvent.hintType) {
          case audio.InterruptHint.INTERRUPT_HINT_PAUSE:
            // 系统强制暂停（临时失去焦点）
            this.isPlayingBeforeInterrupt = player.state === 'playing';
            await this.pause();
            break;

          case audio.InterruptHint.INTERRUPT_HINT_RESUME:
            // 恢复播放
            if (this.isPlayingBeforeInterrupt) {
              await this.play();
            }
            break;

          case audio.InterruptHint.INTERRUPT_HINT_STOP:
            // 系统强制停止（永久失去焦点）
            this.isPlayingBeforeInterrupt = false;
            await this.pause();
            break;

          case audio.InterruptHint.INTERRUPT_HINT_DUCK:
            // 降低音量（默认降至20%）
            break;

          case audio.InterruptHint.INTERRUPT_HINT_UNDUCK:
            // 恢复音量
            break;

          default:
            break;
        }
      } else {
        // 非强制打断
        switch (interruptEvent.hintType) {
          case audio.InterruptHint.INTERRUPT_HINT_PAUSE:
            await this.pause();
            break;
          case audio.InterruptHint.INTERRUPT_HINT_RESUME:
            if (this.isPlayingBeforeInterrupt) {
              await this.play();
            }
            break;
          default:
            break;
        }
      }
    });

  }

  async getAVPlayerInstance() {
    if (this.avPlayer !== null) {
      return this.avPlayer;
    }

    const player = await media.createAVPlayer();
    this.setupAudioInterrupt(player);

    player.on('stateChange', (state: string) => {
      this.triggerStateChange(state);

      switch (state) {
        case 'initialized':
          player.prepare();
          break;
        case 'prepared':
          if (!this.formCached) {
            player.play();
            this.currentPlaybackState = avSession.PlaybackState.PLAYBACK_STATE_PLAY;
            this.updatePlaybackState(avSession.PlaybackState.PLAYBACK_STATE_PLAY);
            this.formCached = false
          } else {
            this.currentPlaybackState = avSession.PlaybackState.PLAYBACK_STATE_PAUSE;
            this.updatePlaybackState(avSession.PlaybackState.PLAYBACK_STATE_PAUSE);
          }
          const duration = player.duration;
          this.triggerDurationChange(duration);
          break;
        case 'playing':
          this.isPlayingBeforeInterrupt = true;
          this.currentPlaybackState = avSession.PlaybackState.PLAYBACK_STATE_PLAY;
          this.updatePlaybackState(avSession.PlaybackState.PLAYBACK_STATE_PLAY);
          this.triggerPlay();
          break;
        case 'paused':
          this.isPlayingBeforeInterrupt = false;
          this.currentPlaybackState = avSession.PlaybackState.PLAYBACK_STATE_PAUSE;
          this.updatePlaybackState(avSession.PlaybackState.PLAYBACK_STATE_PAUSE);
          this.triggerPause();
          break;
        case 'completed':
          if (globalPlaylist.playNext()) {
            return;
          }
          this.isPlayingBeforeInterrupt = false;
          this.currentPlaybackState = avSession.PlaybackState.PLAYBACK_STATE_PAUSE;
          this.updatePlaybackState(avSession.PlaybackState.PLAYBACK_STATE_PAUSE);
          this.triggerCompleted();
          break;
        case 'stopped':
          this.isPlayingBeforeInterrupt = false;
          player.reset();
          this.currentPlaybackState = avSession.PlaybackState.PLAYBACK_STATE_IDLE;
          this.updatePlaybackState(avSession.PlaybackState.PLAYBACK_STATE_IDLE);
          this.triggerStop();
          break;
        default:
          break;
      }
    });

    // 监听缓冲进度
    player.on('bufferingUpdate', (progress: number) => {
      this.triggerBufferingUpdate(progress);
    });

    player.on('error', (error: Error) => {
      this.triggerError(error);
      Logger.error('Player error:', error.message);
    });

    player.on('seekDone', (position) => {
      this.updatePlaybackState(this.currentPlaybackState, position);
    });


    this.avPlayer = player;
    return this.avPlayer;
  }

  async playByPath(path: string, formCached: number, metadata?: avSession.AVMetadata) {
    try {
      this.formCached = formCached == 1
      const player = await this.getAVPlayerInstance();
      await player.reset();
      // 使用文件描述符播放
      const file = fs.openSync(path, fs.OpenMode.READ_ONLY);
      player.fdSrc = {
        fd: file.fd,
        offset: 0,
        length: (fs.statSync(path)).size
      };

      if (metadata && this.avSession) {
        await this.avSession.setAVMetadata(metadata);
      }
      await player.prepare();
      await this.play();
    } catch (error) {
      this.triggerError(error);
      Logger.error('Failed to play raw source:', error.message);
    }
  }

  async playByUrl(url: string, metadata?: avSession.AVMetadata) {
    try {
      const player = await this.getAVPlayerInstance();
      await player.reset();
      player.url = url;

      if (metadata && this.avSession) {
        await this.avSession.setAVMetadata(metadata);
      }

      await player.prepare();
      await this.play();
    } catch (error) {
      this.triggerError(error);
      Logger.error('Failed to play URL:', error.message);
    }
  }

  async updateAVMetadata(metadata: avSession.AVMetadata) {
    if (this.avSession) {
      await this.avSession.setAVMetadata(metadata);
    }
  }

  async play() {
    try {
      const player = await this.getAVPlayerInstance();
      await player.play();
      this.updatePlaybackState(avSession.PlaybackState.PLAYBACK_STATE_PLAY);
      this.triggerPlay();
    } catch (error) {
      this.triggerError(error);
    }
  }

  async pause() {
    try {
      const player = await this.getAVPlayerInstance();
      await player.pause();
      this.updatePlaybackState(avSession.PlaybackState.PLAYBACK_STATE_PAUSE);
      this.triggerPause();
    } catch (error) {
      this.triggerError(error);
    }
  }

  async stop() {
    try {
      const player = await this.getAVPlayerInstance();
      // 如果状态不支持停止，则先暂停再停止
      if (player.state === 'playing') {
        await player.pause();
      }
      await player.stop();
      this.updatePlaybackState(avSession.PlaybackState.PLAYBACK_STATE_IDLE);
      this.triggerStop();
    } catch (error) {
      this.triggerError(error);
    }
  }

  async destroy() {
    try {
      if (this.avPlayer) {
        await this.avPlayer.release();
        this.avPlayer = null;
      }
      if (this.avSession) {
        await this.avSession.destroy();
        this.avSession = null;
      }
      this.clearCallbacks();
    } catch (error) {
      Logger.error('Failed to destroy AVPlayerManager:', error.message);
      this.triggerError(error);
    }
  }
}

export default AVPlayerManager;

export const avPlayerManager = new AVPlayerManager();