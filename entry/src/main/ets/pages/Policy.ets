import web_webview from '@ohos.web.webview';
import router from '@ohos.router';
import { PreferencesUtil } from '../common/PreferenceUtil';

@Entry
@Component
struct PrivacyPolicy {
  controller: web_webview.WebviewController = new web_webview.WebviewController();

  onPageShow() {
    const isConfirmed = PreferencesUtil.get<boolean>("confirmPolicy");
    const customURL = PreferencesUtil.get<string>('customURL')
    if (isConfirmed && customURL) {
      router.replaceUrl({ url: 'pages/Index' });
    }
  }

  onBackPress(): boolean {
    // Prevent back navigation without explicit choice
    return true;
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

  build() {
    Column() {
      RelativeContainer() {
        Web({
          src: 'https://music.yby.zone',
          controller: this.controller
        })
          .height('100%')
          .width('100%')
      }
      .height('80%')
      .width('100%')

      Row() {
        Button('取消')
          .onClick(() => this.handleCancel())
          .backgroundColor('#F5F5F5')
          .fontColor('#333333')
          .width('40%')
          .height(40)
          .margin({ right: 10 })

        Button('确认')
          .onClick(() => this.handleConfirm())
          .backgroundColor('#007DFF')
          .fontColor('#FFFFFF')
          .width('40%')
          .height(40)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ top: 20, bottom: 20 })
    }
    .width('100%')
    .height('100%')
  }
}