import { PreferencesUtil } from '../common/PreferenceUtil'
import { promptAction, router, PromptAction } from '@kit.ArkUI'
import { getBiliUserInfo } from '../api/Bililogin'

@Entry
@Component
struct Settings {
  @Builder
  CacheClear() {
    Row() {
      Column() {
        Row() {
          Text('清除所有请求缓存')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
        }
        .width('100%')

        Text('清除应用中的所有请求缓存数据')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Image($r('app.media.ic_public_arrow_right'))
        .width(32)
        .height(32)
        .fillColor($r('app.color.icon_color'))
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background_two'))
    .borderRadius(12)
    .margin({ bottom: 12 })
    .onClick(() => {
      const caches = PreferencesUtil.getAll()
      if (!caches) {
        promptAction.showToast({ message: '没有可以清除缓存' })
        return
      }
      // 获取所有key为url_开头的缓存
      const cacheKeys = Object.keys(caches).filter(key => key.startsWith('url_'))

      if (cacheKeys.length === 0) {
        promptAction.showToast({ message: '没有可以清除缓存' })
        return
      }

      cacheKeys.forEach(key => {
        PreferencesUtil.delete(key)
      })

      promptAction.showToast({ message: `已清除${cacheKeys.length}条缓存` })
    })
  }

  @State isLoading: boolean = true
  @State isLogin: boolean = false
  @State avatar: string = ''
  @State username: string = ''

  aboutToAppear() {
    this.checkLoginStatus()
  }

  async checkLoginStatus() {
    try {
      const cookies = PreferencesUtil.get<string>('biliCookies')
      if (!cookies) {
        this.avatar = ''
        this.username = ''
        return
      }
      const response = await getBiliUserInfo(cookies)
      if (response.isLogin) {
        this.avatar = response.face
        this.username = response.uname
        this.isLogin = response.isLogin
        this.isLoading = false
      } else {
        PreferencesUtil.delete('biliCookies')
        this.avatar = ''
        this.username = ''
        this.isLogin = false
        promptAction.showToast({ message: '登录失效，尝试重新登录' })
      }
    } catch (error) {
      PreferencesUtil.delete('biliCookies')
      this.avatar = ''
      this.username = ''
      this.isLogin = false
    } finally {
      this.isLoading = false
    }
  }

  handleLogout() {
    PreferencesUtil.delete('biliCookies')
    this.avatar = ''
    this.username = ''
    this.isLogin = false
    promptAction.showToast({ message: '已退出登录' })
  }

  @Builder
  BilibiliLogin() {
    Row() {
      if (this.isLoading) {
        LoadingProgress()
          .width(32)
          .height(32)
      } else if (this.isLogin) {
        Column() {
          Row() {
            Image(this.avatar)
              .width(48)
              .height(48)
              .borderRadius(24)
              .margin({ right: 12 })

            Column() {
              Text(this.username)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_primary'))
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Text('注销')
              .fontSize(15)
              .fontColor($r('app.color.text_secondary'))
              .margin({ right: 5 })

            Image($r('app.media.ic_public_arrow_right'))
              .width(32)
              .height(32)
              .fillColor($r('app.color.icon_color'))
          }
        }
        .width('100%')
      } else {
        Column() {
          Row() {
            Text('登录哔哩哔哩账号')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
          }
          .width('100%')

          Text('登录后可以同步您的收藏和历史记录')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Image($r('app.media.ic_public_arrow_right'))
          .width(32)
          .height(32)
          .fillColor($r('app.color.icon_color'))
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background_two'))
    .borderRadius(12)
    .margin({ bottom: 12 })
    .onClick(() => {
      if (!this.isLogin && !this.isLoading) {
        router.pushUrl({ url: 'pages/Login' })
      } else if (this.isLogin) {
        // 获取 PromptAction 对象
        const promptAction: PromptAction = this.getUIContext().getPromptAction();
        promptAction.showDialog({
          title: '确认退出',
          message: '您确定要退出登录吗？',
          buttons: [
            {
              text: '确定',
              color: '#FF0000'
            },
            {
              text: '取消',
              color: '#0000FF'
            }
          ]
        }).then((result) => {
          if (result.index === 0) {
            this.handleLogout();
          } else {
            // 用户取消操作，无需处理
          }
        });
      }
    })
  }

  @Builder
  AboutApp() {
    Row() {
      Column() {
        Row() {
          Text('关于应用')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
        }
        .width('100%')

        Text('查看应用版本和使用须知')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Image($r('app.media.ic_public_arrow_right'))
        .width(32)
        .height(32)
        .fillColor($r('app.color.icon_color'))
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background_two'))
    .borderRadius(12)
    .onClick(() => {
      router.pushUrl({ url: 'pages/Policy' });
    })
  }

  build() {
    Column() {
      RelativeContainer() {
        Column() {
          Row() {
            Text('设置')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
          }
          .width('100%')
          .padding({
            left: 16,
            right: 16,
            top: 16,
            bottom: 4
          })

          Scroll() {
            Column({ space: 12 }) {
              this.BilibiliLogin()
              this.CacheClear()
              this.AboutApp()
            }
            .width('100%')
            .padding({
              left: 16,
              right: 16
            })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .width('100%')
        }
        .margin({
          left: 35,
          right: 35,
          top: 20,
          bottom: 20
        })
      }
      .height('80%')
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}