import { QR_STATUS, generateQRCode, pollQRStatus, saveCookies } from '../api/Bililogin';
import { promptAction } from '@kit.ArkUI'
import { PreferencesUtil } from '../common/PreferenceUtil'
import { getBiliUserInfo } from '../api/Bililogin'

@Entry
@Component
export struct Login {
  @State isCreatingQR: boolean = false;
  @State qrCodeUrl: string = '';
  @State qrCodeKey: string = '';
  @State qrStatus: string = '等待扫码';
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
      const response = await generateQRCode();
      this.qrCodeUrl = response.url;
      this.qrCodeKey = response.qrcode_key;

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
    }, 3000);
  }

  async pollQRStatus() {
    if (!this.qrCodeKey) {
      return;
    }

    try {
      const response = await pollQRStatus(this.qrCodeKey);
      const statusCode = response.code;

      // 根据不同状态码更新UI
      if (statusCode === QR_STATUS.WAITING) {
        this.qrStatus = '等待扫码';
      } else if (statusCode === QR_STATUS.SCANNED) {
        this.qrStatus = '已扫码，请在手机上确认';
      } else if (statusCode === QR_STATUS.SUCCESS) {
        this.qrStatus = '登录成功';

        if (response.url) {
          await saveCookies(response.url)
        }

        // 获取用户信息
        const loginRes = await getBiliUserInfo(PreferencesUtil.get<string>('biliCookies'))
        promptAction.showToast({ message: '登录成功，欢迎使用，亲爱的' + loginRes.uname })

        // 清除轮询
        if (this.pollTimer !== -1) {
          clearInterval(this.pollTimer);
          this.pollTimer = -1;
        }

      } else {
        this.qrStatus = `错误: ${response.message}`;
      }
    } catch (error) {
      console.error('Error polling QR status:', error);
      this.qrStatus = '检查状态失败';
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