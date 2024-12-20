import { getAnonymous } from "../common/RequestUtil"
import promptAction from '@ohos.promptAction'
import { StyleConstants } from '../common/Constant'
import { Account, AccountProfile } from "../type/Account"
import { PreferencesUtil } from "../common/PreferenceUtil"
import { webview } from '@kit.ArkWeb'
import { BusinessError } from '@kit.BasicServicesKit'
import { router } from "@kit.ArkUI"
import { EventBus } from "../common/EventBus"

interface QRKeyData {
  unikey: string
}

interface QRKeyResponseData {
  code: number
  data: QRKeyData
}

interface QRKeyResponse {
  data: QRKeyResponseData
}

interface QRImageData {
  qrimg: string
}

interface QRImageResponseData {
  code: number
  data: QRImageData
}

interface QRImageResponse {
  data: QRImageResponseData
}

@Observed
class LoginStatus {
  code: number = 0
  message: string = ''
  cookie?: string = ''
}

interface LoginStatusResponse {
  data: LoginStatus
}

interface LoginResponseData {
  account: Account
  profile: AccountProfile
}

interface LoginResponseBody {
  code: number
  data: LoginResponseData
}

interface LoginResponse {
  data: LoginResponseBody
}

interface StatusQuery {
  cookie: string
}

@Component
export struct Login {
  @State showLogin: boolean = false
  @State showSearch: boolean = false
  @State showWebLogin: boolean = false
  @State qrImg: string = ''
  @State isCreatingQR: boolean = false
  @State isExpired: boolean = false
  @State webMessage: string = ''
  private checkStatusTimer: number = -1
  controller: webview.WebviewController = new webview.WebviewController()
  @State pcUserAgent: string =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36 Edg/130.0.0.0'

  private anonymous = getAnonymous()

  @State count:number = 0

  aboutToDisappear() {
    if (this.checkStatusTimer !== -1) {
      clearTimeout(this.checkStatusTimer)
    }
  }

  async createQRCode() {
    if (this.isCreatingQR) {
      return
    }
    this.isCreatingQR = true
    this.isExpired = false

    try {
      const timestamp = new Date().getTime()
      const keyRes: QRKeyResponse = await this.anonymous.get(`/login/qr/key?timestamp=${timestamp}`)
      const key = keyRes.data.data.unikey

      const qrRes: QRImageResponse =
        await this.anonymous.get(`/login/qr/create?key=${key}&qrimg=true&timestamp=${timestamp}`)
      this.qrImg = qrRes.data.data.qrimg

      this.checkLoginStatus(key)
      this.isCreatingQR = false
    } catch (error) {
      console.error('创建二维码失败', error.message)
      this.isCreatingQR = false
    }
  }

  async checkLoginStatus(key: string) {
    try {
      const timestamp = new Date().getTime()
      const res: LoginStatusResponse = await this.anonymous.get(`/login/qr/check?key=${key}&timestamp=${timestamp}`)
      const status = res.data

      if (status.code === 800) {
        this.isExpired = true
        this.isCreatingQR = false
      } else if (status.code === 803) {
        if (status.cookie) {
          this.getLoginStatus(status.cookie)
        } else {
          promptAction.showToast({
            message: '登录失败，请重新尝试！'
          })
        }
        this.isCreatingQR = false
      } else {
        this.checkStatusTimer = setTimeout(() => {
          this.checkLoginStatus(key)
        }, 3000) as number
      }
    } catch (error) {
      console.error('检查登录状态失败', error.message)
      this.isCreatingQR = false
    }
  }

  async extractCookie() {
    try {
      let cookie = webview.WebCookieManager.fetchCookieSync('https://music.163.com')
      if (cookie) {
        this.getLoginStatus(cookie)
        this.showWebLogin = false
      } else {
        promptAction.showToast({
          message: '获取登录信息失败，请重试！'
        })
      }
    } catch (error) {
      console.error('获取Cookie失败', error.message)
      promptAction.showToast({
        message: '获取Cookie失败：' + error.message
      })
    }
  }

  async getLoginStatus(cookie: string) {
    try {
      const timestamp = new Date().getTime()
      const res: LoginResponse = await this.anonymous.post('/login/status', { cookie } as StatusQuery, {
        params: { timestamp }
      })

      const account = res.data.data.account
      const profile = res.data.data.profile

      EventBus.send("ViewChange", "library")

      if (PreferencesUtil.isInitialized()) {
        // 给Cookie加OS=pc
        cookie = cookie + '; os=pc'
        PreferencesUtil.put("account", account)
        PreferencesUtil.put("profile", profile)
        PreferencesUtil.put("cookie", cookie)
        PreferencesUtil.put("signAt", Date.now())
        AppStorage.setOrCreate('ValidCookie', true)
        AppStorage.setOrCreate('Profile', profile)

        promptAction.showToast({
          message: '登录成功！'
        })

        this.showLogin = false
        this.showWebLogin = false


      } else {
        promptAction.showToast({
          message: '持久化服务错误！'
        })
      }
    } catch (error) {
      console.error('获取登录状态失败', error.message)
    }
  }

  build() {
    Column() {
      // 二维码登录卡片
      Column() {
        Column() {
          Text('扫码登录账号')
            .fontSize(24)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.primary_blue'))
            .margin({ bottom: 8 })

          Text('请按照规范对自定义API服务器添加基础验证')
            .fontSize(16)
            .fontColor($r('app.color.text_placeholder'))

        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .padding(20)
        .onClick(() => {
          this.showLogin = true
          this.showWebLogin = false
          this.createQRCode()
        })
      }
      .width('90%')
      .backgroundColor($r('app.color.background_gray'))
      .borderRadius(16)
      .margin({ bottom: 12 })
      .bindSheet($$this.showLogin, this.showWebLogin ? this.WebLogin : this.Login, {
        showClose: false,
        detents: [SheetSize.MEDIUM, SheetSize.LARGE],
        dragBar: true,
        backgroundColor: $r('app.color.dialog_background'),
        onDisappear: () => {
          if (this.checkStatusTimer !== -1) {
            clearTimeout(this.checkStatusTimer)
          }
        }
      })
      .gesture(
        LongPressGesture({ repeat: true, duration: 500 })
          .onAction((event: GestureEvent) => {
            this.count++
            if (this.count === 3) {
              this.showWebLogin = true
              this.showLogin = true
            }
          })

          .onActionEnd((event: GestureEvent) => {
            this.count = 0
            this.showWebLogin = false
          })
      )



      Text('设置 API 服务器')
        .fontSize(14)
        .fontColor($r('app.color.text_placeholder'))
        .margin({ bottom: 20 })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/Setting'
          })
        })
    }
  }


  @Builder
  Login() {
    Column() {
      Text('扫码登录')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .alignSelf(ItemAlign.Start)
        .margin({ left: 20, top: 20, bottom: 40 })

      Stack() {
        if (this.qrImg) {
          Image(this.qrImg)
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

        if (this.isExpired) {
          Column() {
            Text('二维码已过期')
              .fontSize(16)
              .fontColor(Color.White)
            Button('点击刷新')
              .onClick(() => this.createQRCode())
              .margin({ top: 8 })
              .backgroundColor($r('app.color.secondary_blue'))
              .width(120)
              .height(40)
              .borderRadius(20)
          }
          .width('100%')
          .height('100%')
          .backgroundColor($r('app.color.expired_mask'))
          .borderRadius(8)
          .justifyContent(FlexAlign.Center)
        }
      }
      .width(200)
      .height(200)
      .margin({ bottom: 20 })

      if (!this.isExpired && this.qrImg) {
        Button('刷新二维码')
          .onClick(() => this.createQRCode())
          .enabled(!this.isCreatingQR)
          .width(120)
          .height(40)
          .borderRadius(20)
          .backgroundColor(this.isCreatingQR ? $r('app.color.disabled_button') : $r('app.color.secondary_blue'))
      }
    }
    .width('100%')
    .padding({ top: 12, bottom: 20 })
    .height('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  WebLogin() {
    Column() {
      Row() {
        Text('网页登录')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        Blank()
        Button('获取登录信息')
          .onClick(() => {
            this.extractCookie()
          })
          .backgroundColor($r('app.color.secondary_blue'))
          .borderRadius(20)
      }
      .width('100%')
      .padding(20)

      Web({
        src: '',
        controller: this.controller
      })
        .width('100%')
        .height('80%')
        .onControllerAttached(() => {
          console.log("onControllerAttached")
          try {
            this.controller.setCustomUserAgent(this.pcUserAgent)
            this.controller.loadUrl("https://music.163.com/#/login")
          } catch (error) {
            console.error(`ErrorCode: ${(error as BusinessError).code}, Message: ${(error as BusinessError).message}`)
          }
        })

      Text('请在网页中完成登录后点击"获取登录信息"按钮')
        .fontSize(14)
        .fontColor($r('app.color.text_tertiary'))
        .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
  }
}