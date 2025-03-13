import axios from '@ohos/axios';
import { PreferencesUtil } from '../common/PreferenceUtil';

interface QRKeyResponseData {
  url: string;
  qrcode_key: string;
}

interface QRKeyResponse {
  code: number;
  message: string;
  ttl: number;
  data: QRKeyResponseData;
}

interface Cookie {
  name: string;
  value: string;
  http_only: number;
  expires: number;
}

interface CookieInfo {
  cookies: Array<Cookie>;
}

interface QRPollResponseData {
  refresh_token: string;
  timestamp: number;
  code: number;
  message: string;
  cookie_info?: CookieInfo;
}

interface QRPollResponse {
  code: number;
  message: string;
  ttl: number;
  data: QRPollResponseData;
}

const QR_POLL_INTERVAL = 3000;

@Entry
@Component
export struct Login {
  @State isCreatingQR: boolean = false;
  @State qrCodeUrl: string = '';
  @State qrCodeKey: string = '';
  @State qrStatus: string = '等待扫码';
  @State UserAgent: string =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36 Edg/130.0.0.0';
  private pollTimer: number = -1;

  aboutToAppear() {
    this.generateQRCode();
  }

  aboutToDisappear() {
    // 清除轮询定时器
    if (this.pollTimer !== -1) {
      clearInterval(this.pollTimer);
      this.pollTimer = -1;
    }
  }

  async generateQRCode() {
    if (this.pollTimer !== -1) {
      clearInterval(this.pollTimer);
      this.pollTimer = -1;
    }

    this.isCreatingQR = true;
    this.qrStatus = '等待扫码';
    try {
      const response: QRKeyResponse =
        (await axios.get('https://passport.bilibili.com/x/passport-login/web/qrcode/generate',
          { headers: { 'User-Agent': this.UserAgent } })).data;
      this.qrCodeUrl = response.data.url;
      this.qrCodeKey = response.data.qrcode_key;

      // 开始轮询检查二维码状态
      this.startQRPoll();
    } catch (error) {
      console.error('Error generating QR code:', error);
      this.qrStatus = '获取二维码失败';
    } finally {
      this.isCreatingQR = false;
    }
  }

  startQRPoll() {
    // 设置轮询定时器
    this.pollTimer = setInterval(() => {
      this.pollQRStatus();
    }, QR_POLL_INTERVAL);
  }

  async pollQRStatus() {
    if (!this.qrCodeKey) {
      return;
    }

    try {
      const response: QRPollResponse = (await axios.get(
        'https://passport.bilibili.com/x/passport-login/web/qrcode/poll', {
        params: { qrcode_key: this.qrCodeKey },
        headers: { 'User-Agent': this.UserAgent }
      }
      )).data;

      const statusCode = response.data.code;

      // 根据不同状态码更新UI
      if (statusCode === 86101) {
        this.qrStatus = '等待扫码';
      } else if (statusCode === 86090) {
        this.qrStatus = '已扫码，请在手机上确认';
      } else if (statusCode === 0) {
        this.qrStatus = '登录成功';

        // 清除轮询
        if (this.pollTimer !== -1) {
          clearInterval(this.pollTimer);
          this.pollTimer = -1;
        }

        // 处理cookie
        if (response.data.cookie_info && response.data.cookie_info.cookies) {
          const cookies = response.data.cookie_info.cookies;
          const cookieString = cookies.map(cookie => `${cookie.name}=${cookie.value}`).join('; ');

          // 保存cookie到preferences
          this.saveCookies(cookieString);
        }
      } else {
        this.qrStatus = `错误: ${response.data.message}`;
      }
    } catch (error) {
      console.error('Error polling QR status:', error);
      this.qrStatus = '检查状态失败';
    }
  }

  async saveCookies(cookieString: string) {
    try {
      PreferencesUtil.put('biliCookies', cookieString);
      console.log('Cookies saved successfully');
    } catch (error) {
      console.error('Failed to save cookies:', error);
    }
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.Start }) {
        TabContent() {
          Column() {
            Stack() {
              if (this.qrCodeUrl) {
                QRCode(this.qrCodeUrl)
                  .width(200)
                  .height(200)
                  .borderRadius(8)
                  .borderColor($r('app.color.border_color'))
              } else {
                Column() {
                  LoadingProgress()
                    .width(32)
                    .height(32)
                    .color($r('app.color.loading_color'))
                    .margin({ bottom: 8 })
                  Text('获取二维码中...')
                    .fontSize(14)
                    .fontColor($r('app.color.text_tertiary'))
                }
                .width('100%')
                .height('100%')
                .justifyContent(FlexAlign.Center)
              }
            }
            .width(200)
            .height(200)
            .margin({ bottom: 16 })

            Text(this.qrStatus)
              .fontSize(16)
              .fontColor(this.qrStatus === '登录成功' ? '#4caf50' :
                this.qrStatus.startsWith('错误') ? '#f44336' : '#333333')
              .margin({ bottom: 12 })

            Button('刷新二维码')
              .onClick(() => this.generateQRCode())
              .margin({ top: 8 })
          }
          .width('100%')
          .padding(16)
        }
        .tabBar('扫码登录')

        TabContent() {
          Text('输入框').fontSize(30)
        }
        .tabBar('手机号登录')

        TabContent() {
          Text('输入').fontSize(30)
        }
        .tabBar('密码登录')
      }
    }
  }
}
