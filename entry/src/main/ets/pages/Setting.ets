import { StyleConstants } from '../common/Constant'
import { PreferencesUtil } from '../common/PreferenceUtil'
import { promptAction } from '@kit.ArkUI'
import { qualityDescriptions, LevelType } from '../common/APIHelper'
import { updateBaseURL } from '../common/RequestUtil'

@CustomDialog
struct UrlInputDialog {
  controller: CustomDialogController
  confirm: (value: string) => void = () => {
  }
  cancel: () => void = () => {
  }
  defaultValue: string = ''
  @State value: string = ''

  aboutToAppear() {
    this.value = this.defaultValue
  }

  // URL验证正则
  private validateUrl(url: string): boolean {
    const urlPattern = /^(https?:\/\/)([\w-]+\.)+[\w-]+(\/[\w-./?%&=]*)?$/
    return urlPattern.test(url)
  }

  build() {
    Column() {
      Text('设置API服务器')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 16, top: 8 })
        .width('100%')

      TextInput({
        text: this.value,
        placeholder: '请输入API服务器地址',
      })
        .onChange((value: string) => {
          this.value = value
        })
        .width('100%')
        .height(48)
        .margin({ bottom: 24 })
        .borderRadius(8)

      Row({ space: 12 }) {
        Button('取消', { type: ButtonType.Capsule })
          .onClick(() => {
            this.controller.close()
            this.cancel()
          })
          .backgroundColor(Color.Transparent)
          .fontColor('#666')
          .width(100)

        Button('确定', { type: ButtonType.Capsule })
          .onClick(() => {
            if (!this.value) {
              promptAction.showToast({ message: '请输入服务器地址' })
              return
            }
            if (!this.validateUrl(this.value)) {
              promptAction.showToast({ message: '请输入有效的URL' })
              return
            }
            this.confirm(this.value)
            this.controller.close()
          })
          .width(100)
      }
    }
    .backgroundColor(Color.White)
    .width('100%')
    .expandSafeArea()
    .padding(24)
  }
}

@Entry
@Component
struct Settings {
  @State customApiUrl: string = ''
  @State selectedQuality: keyof LevelType = PreferencesUtil.get<keyof LevelType>('defaultLevel') ?? "standard"
  @State autoCache: boolean = PreferencesUtil.get<boolean>("autoCache") ?? false

  dialogController: CustomDialogController = new CustomDialogController({
    builder: UrlInputDialog({
      cancel: () => {
      },
      confirm: (value: string) => {
        this.customApiUrl = value
        PreferencesUtil.put('customURL', value)
        updateBaseURL(value)
        promptAction.showToast({ message: '设置已保存' })
      }
    }),
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -20 },
    customStyle: true,
    maskColor: '#00000080'
  })

  @Builder
  AutoCacheSetting() {
    Column() {
      Row() {
        Column() {
          Row() {
            Text('自动缓存下一首')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)

            Toggle({ type: ToggleType.Switch, isOn: this.autoCache })
              .onChange((isOn: boolean) => {
                this.autoCache = isOn
                PreferencesUtil.put('autoCache', isOn)
                promptAction.showToast({
                  message: isOn ? '已开启自动缓存' : '已关闭自动缓存'
                })
              })
              .margin({ left: 8 })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          Text('注意流量，可以提升播放体验')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .shadow({
        radius: 12,
        color: '#00000008',
        offsetX: 0,
        offsetY: 2
      })
    }
  }

  aboutToAppear() {
    // 读取保存的自定义URL
    const savedUrl = PreferencesUtil.get<string>('customURL')
    if (savedUrl) {
      this.customApiUrl = savedUrl
    }

    // 读取保存的音质设置
    const savedQuality = PreferencesUtil.get<string>('defaultLevel') ?? "standard"
    if (savedQuality) {
      this.selectedQuality = savedQuality as keyof LevelType
    }
  }

  @Builder
  ApiUrlSetting() {
    Column() {
      Row() {
        Column() {
          Text('API 服务器')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)

          if (this.customApiUrl) {
            Text('当前: ' + this.customApiUrl)
              .fontSize(14)
              .fontColor('#666')
              .margin({ top: 4 })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          } else {
            Text('使用默认服务器')
              .fontSize(14)
              .fontColor('#666')
              .margin({ top: 4 })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        if (this.customApiUrl) {
          Button({ type: ButtonType.Circle }) {
            Image($r('app.media.ic_close'))
              .width(20)
              .height(20)
              .fillColor('#666')
          }
          .width(32)
          .height(32)
          .backgroundColor('rgba(0,0,0,0.05)')
          .margin({ right: 8 })
          .onClick(() => {
            PreferencesUtil.delete('customURL')
            this.customApiUrl = ''
            updateBaseURL()
            promptAction.showToast({ message: '已恢复默认服务器' })
          })
        }

        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.ic_edit'))
            .width(20)
            .height(20)
            .fillColor('#666')
        }
        .width(32)
        .height(32)
        .backgroundColor('rgba(0,0,0,0.05)')
        .onClick(() => {
          this.dialogController.open()
        })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .shadow({
        radius: 12,
        color: '#00000008',
        offsetX: 0,
        offsetY: 2
      })
    }
  }

  @Builder
  QualitySetting() {
    Column() {
      Text('音质设置')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 12 })
        .width('100%')

      List() {
        ForEach(Object.keys(qualityDescriptions), (key: string) => {
          ListItem() {
            Row() {
              Radio({ value: key, group: 'quality' })
                .checked(this.selectedQuality === key)
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.selectedQuality = key as keyof LevelType
                    PreferencesUtil.put('defaultLevel', key)
                    promptAction.showToast({ message: '音质设置已更新' })
                  }
                })
              Text(Object(qualityDescriptions)[key])
                .fontSize(14)
                .margin({ left: 8 })
            }
            .width('100%')
            .height(48)
            .onClick(() => {
              this.selectedQuality = key as keyof LevelType
              PreferencesUtil.put('defaultLevel', key)
              promptAction.showToast({ message: '音质设置已更新' })
            })
          }
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 12,
      color: '#00000008',
      offsetX: 0,
      offsetY: 2
    })
  }

  build() {
    Column() {
      Row() {
        Text('设置')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
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
          this.ApiUrlSetting()
          this.QualitySetting()
          this.AutoCacheSetting()
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .width('100%')
    }
    .width(StyleConstants.FULL_WIDTH)
    .height(StyleConstants.FULL_HEIGHT)
    .backgroundColor('#f5f5f5')
    .expandSafeArea()
  }
}