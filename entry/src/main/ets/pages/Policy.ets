import web_webview from '@ohos.web.webview';
import router from '@ohos.router';
import { PreferencesUtil } from '../common/PreferenceUtil';
import { openInWeb } from '../common/openInWeb';

@Entry
@Component
struct PrivacyPolicy {
  controller: web_webview.WebviewController = new web_webview.WebviewController();

  onPageShow() {
    const isConfirmed = PreferencesUtil.get<boolean>("confirmPolicy");
    const biliCookies = PreferencesUtil.get<string>('biliCookies')
    if (isConfirmed && biliCookies) {
      router.replaceUrl({ url: 'pages/Index' });
    }
  }

  onBackPress(): boolean {
    // Prevent back navigation without explicit choice
    return true;
  }

  firstIn(): boolean {
    return PreferencesUtil.get<boolean>("confirmPolicy");
  }

  async handleConfirm() {
    try {
      PreferencesUtil.put("confirmPolicy", true);
      router.pushUrl({ url: 'pages/Setting' });
    } catch (error) {
      console.error('Failed to save privacy confirmation:', error);
    }
  }

  handleCancel() {
    // 退出
    getContext(this).getApplicationContext().killAllProcesses();
  }

  @Builder
  CopyrightStatement() {
    // 版权声明
    Row() {
      Column() {
        Row() {
          Text('版权声明')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
        }
        .width('100%')

        Text('本应用仅供个人学习交流使用，所有音乐版权归原音乐平台及版权方所有')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background_two'))
    .borderRadius(12)
    .margin({ bottom: 12 })
  }

  @Builder
  Disclaimer() {
    // 免责声明
    Row() {
      Column() {
        Row() {
          Text('免责声明')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
        }
        .width('100%')

        Text('本应用不存储任何音乐文件，仅作为音乐资源的展示工具。使用本应用产生的任何法律责任需由用户自行承担')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background_two'))
    .borderRadius(12)
    .margin({ bottom: 12 })
  }

  @Builder
  UsageSuggestion() {
    // 使用建议
    Row() {
      Column() {
        Row() {
          Text('使用建议')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
        }
        .width('100%')

        Text('建议支持正版音乐平台，本应用仅作为临时替代方案，请尊重音乐创作者的劳动成果')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background_two'))
    .borderRadius(12)
    .margin({ bottom: 12 })
  }

  @Builder
  UserAgreement() {
    // 用户协议
    Row() {
      Column() {
        Row() {
          Text('用户协议')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
        }
        .width('100%')

        Text('使用本应用即表示您同意遵守相关法律法规，不得将本应用用于任何商业用途或违法活动')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background_two'))
    .borderRadius(12)
    .margin({ bottom: 12 })
  }

  @Builder
  PrivacyPolicy() {
    // 隐私政策
    Row() {
      Column() {
        Row() {
          Text('隐私政策')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
        }
        .width('100%')

        Text('本应用会在本地存储必要的缓存数据和登录信息，但不会收集或上传您的个人信息。第三方平台的隐私政策请参考其官方说明')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background_two'))
    .borderRadius(12)
    .margin({ bottom: 12 })
  }

  @Builder
  OpenSourceInfo() {
    // 开源信息
    Text('开源项目地址: TNXG/harmony-next-music-sharing')
      .fontSize(14)
      .fontColor('#007DFF')
      .margin({ top: 16 })
      .onClick(() => {
        openInWeb('https://github.com/TNXG/harmony-next-music-sharing');
      })
  }

  @Builder
  ActionButtons() {
    Row() {
      if (!(this.firstIn())) {
        Button('取消')
          .onClick(() => this.handleCancel())
          .backgroundColor('#F5F5F5')
          .fontColor('#333333')
          .width('40%')
          .height(40)
          .margin({ right: 10 })
      }

      Button('确认')
        .onClick(() => this.handleConfirm())
        .backgroundColor('#007DFF')
        .fontColor('#FFFFFF')
        .width('40%')
        .height(40)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 20 })
  }

  build() {
    Column() {
      RelativeContainer() {
        Column() {
          Row() {
            Text('使用须知')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
          }
          .width('100%')
          .padding({
            left: 16,
            right: 16,
            top: 16,
            bottom: 16
          })

          Scroll() {
            Column({ space: 12 }) {
              this.CopyrightStatement()
              this.Disclaimer()
              this.UsageSuggestion()
              this.UserAgreement()
              this.PrivacyPolicy()
            }
          }
          .layoutWeight(1)
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

      this.OpenSourceInfo()
      this.ActionButtons()
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}