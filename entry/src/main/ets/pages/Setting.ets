import { StyleConstants } from '../common/Constant'
import { PreferencesUtil } from '../common/PreferenceUtil'
import { promptAction } from '@kit.ArkUI'
import { qualityDescriptions, QualityLevel, qualityLevels, setIgnoreGray } from '../common/APIHelper'
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

  // URL验证正则，允许http和https以及带端口号的URL
  private validateUrl(url: string): boolean {
    const urlPattern = /^(http|https):\/\/[a-zA-Z0-9-.]+(:\d+)?(\/[a-zA-Z0-9-._?&=]*)?$/
    return urlPattern.test(url)
  }

  build() {
    Column() {
      Text('设置API服务器')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 16, top: 8 })
        .width('100%')
        .fontColor($r('app.color.text_primary'))

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
          .fontColor($r('app.color.text_secondary'))
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
    .backgroundColor($r('app.color.dialog_background'))
    .width('100%')
    .expandSafeArea()
    .padding(24)
  }
}

@Entry
@Component
struct Settings {
  @State customApiUrl: string = ''
  @State selectedQuality: QualityLevel = PreferencesUtil.get<QualityLevel>('defaultLevel') ?? "standard"
  @State autoCache: boolean = PreferencesUtil.get<boolean>("autoCache") ?? false
  @State forceWebApi: boolean = PreferencesUtil.get<boolean>("forceWebApi") ?? false
  @State ignoreGray: boolean = PreferencesUtil.get<boolean>("ignoreGray") ?? false

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
    maskColor: $r('app.color.dialog_mask')
  })

  @Builder
  ForceWebApiSetting() {
    Column() {
      Row() {
        Column() {
          Row() {
            Text('强制使用网页端协议')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))

            Toggle({ type: ToggleType.Switch, isOn: this.forceWebApi })
              .onChange((isOn: boolean) => {
                this.forceWebApi = isOn
                PreferencesUtil.put('forceWebApi', isOn)
                promptAction.showToast({
                  message: isOn ? '已强制网页端协议' : '已关闭强制网页端协议'
                })
              })
              .margin({ left: 8 })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          Text('避免官方模式下混用API造成的灰标')
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
      .shadow({
        radius: 12,
        color: $r('app.color.card_shadow'),
        offsetX: 0,
        offsetY: 2
      })
    }
  }

  // 忽略灰标 设置
  @Builder
  IgnoreGraySetting() {
    Column() {
      Row() {
        Column() {
          Row() {
            Text('忽略灰标')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))

            Toggle({ type: ToggleType.Switch, isOn: this.ignoreGray })
              .onChange((isOn: boolean) => {
                this.ignoreGray = isOn
                PreferencesUtil.put('ignoreGray', isOn)
                setIgnoreGray(isOn)
                promptAction.showToast({
                  message: isOn ? '已开启忽略灰标' : '已关闭忽略灰标'
                })
              })
              .margin({ left: 8 })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          Text('在列表内不展示灰标情况，但并不保证播放正常')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 4 })
          Text('如果一首歌长时间没有加载，那么可能是真的没办法播放')
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
      .shadow({
        radius: 12,
        color: $r('app.color.card_shadow'),
        offsetX: 0,
        offsetY: 2
      })
    }
  }


  @Builder
  AutoCacheSetting() {
    Column() {
      Row() {
        Column() {
          Row() {
            Text('自动缓存下一首')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))

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
      .shadow({
        radius: 12,
        color: $r('app.color.card_shadow'),
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
    const savedQuality = PreferencesUtil.get<QualityLevel>('defaultLevel') ?? "standard"
    if (savedQuality) {
      if (qualityLevels.includes(savedQuality)) {
        this.selectedQuality = savedQuality
      } else {
        this.selectedQuality = "standard"
        PreferencesUtil.put('defaultLevel', 'standard')
      }
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
            .fontColor($r('app.color.text_primary'))

          if (this.customApiUrl) {
            Text('当前: ' + this.customApiUrl)
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 4 })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          } else {
            Text('使用默认服务器')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
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
              .fillColor($r('app.color.icon_color'))
          }
          .width(32)
          .height(32)
          .backgroundColor($r('app.color.button_ghost_background'))
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
            .fillColor($r('app.color.icon_color'))
        }
        .width(32)
        .height(32)
        .backgroundColor($r('app.color.button_ghost_background'))
        .onClick(() => {
          this.dialogController.open()
        })
      }
      .width('100%')
      .padding(16)
      .backgroundColor($r('app.color.card_background_two'))
      .borderRadius(12)
      .shadow({
        radius: 12,
        color: $r('app.color.card_shadow'),
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
        .fontColor($r('app.color.text_primary'))

      List() {
        ForEach(Object.keys(qualityDescriptions), (key: string) => {
          ListItem() {
            Row() {
              Radio({ value: key, group: 'quality' })
                .checked(this.selectedQuality === key)
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.selectedQuality = key as QualityLevel
                    PreferencesUtil.put('defaultLevel', key)
                    promptAction.showToast({ message: '音质设置已更新' })
                  }
                })
              Text(Object(qualityDescriptions)[key])
                .fontSize(14)
                .margin({ left: 8 })
                .fontColor($r('app.color.text_primary'))
            }
            .width('100%')
            .height(48)
            .onClick(() => {
              this.selectedQuality = key as QualityLevel
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
    .backgroundColor($r('app.color.card_background_two'))
    .borderRadius(12)
    .shadow({
      radius: 12,
      color: $r('app.color.card_shadow'),
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
          this.ApiUrlSetting()
          this.QualitySetting()
          this.AutoCacheSetting()
          this.ForceWebApiSetting()
          this.IgnoreGraySetting()
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
    .backgroundColor($r('app.color.page_background'))
    .expandSafeArea()
  }
}