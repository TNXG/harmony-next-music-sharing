import { EventBus } from "../common/EventBus"
import { promptAction } from "@kit.ArkUI"

@CustomDialog
struct CustomTimeDialog {
  controller: CustomDialogController
  @State value: string = ''

  build() {
    Column() {
      Text('自定义时间')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 16, top: 8 })
        .width('100%')
        .fontColor($r('app.color.text_primary'))

      TextInput({
        placeholder: '请输入时间（分钟）',
      })
        .onChange((value: string) => {
          this.value = value
        })
        .type(InputType.Number)
        .width('100%')
        .height(48)
        .margin({ bottom: 24 })
        .borderRadius(8)
        .backgroundColor($r('app.color.search_background'))

      Row({ space: 12 }) {
        Button('取消', { type: ButtonType.Capsule })
          .onClick(() => {
            this.controller.close()
          })
          .backgroundColor(Color.Transparent)
          .fontColor($r('app.color.text_secondary'))
          .width(100)

        Button('确定', { type: ButtonType.Capsule })
          .onClick(() => {
            const minutes = parseInt(this.value)
            if (!this.value || isNaN(minutes) || minutes <= 0) {
              promptAction.showToast({ message: '请输入有效的时间' })
              return
            }
            EventBus.send('SetTimer', minutes)
            this.controller.close()
          })
          .width(100)
      }
    }
    .backgroundColor($r('app.color.dialog_background'))
    .width('100%')
    .padding(24)
  }
}

@Component
export struct TimerSelector {
  @State remainingTime: string = ''
  private timerId: number | null = null
  // 预设时间选项（分钟）
  private readonly timeOptions: number[] = [10, 15, 20, 30, 45, 60, 90, 120]
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomTimeDialog({}),
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -20 },
    customStyle: true,
    maskColor: $r('app.color.dialog_mask')
  })

  aboutToAppear() {
    EventBus.listen<number | null>('TimerUpdated', (timestamp) => {
      if (timestamp) {
        this.updateRemainingTime(timestamp)
        this.startCountdown(timestamp)
      } else {
        this.remainingTime = ''
        if (this.timerId !== null) {
          clearInterval(this.timerId)
          this.timerId = null
        }
      }
    })

    EventBus.send('GetTimerStatus')
  }

  aboutToDisappear() {
    if (this.timerId !== null) {
      clearInterval(this.timerId)
      this.timerId = null
    }
  }

  private updateRemainingTime(endTime: number) {
    const remaining = endTime - Date.now()
    if (remaining <= 0) {
      this.remainingTime = ''
      return
    }
    const minutes = Math.floor(remaining / 60000)
    const seconds = Math.floor((remaining % 60000) / 1000)
    this.remainingTime = `${minutes}:${seconds.toString().padStart(2, '0')}`
  }

  private startCountdown(endTime: number) {
    if (this.timerId !== null) {
      clearInterval(this.timerId)
    }
    this.timerId = setInterval(() => {
      this.updateRemainingTime(endTime)
    }, 1000)
  }

  @Builder
  TimeOption(minutes: number) {
    Button({ type: ButtonType.Circle }) {
      Column() {
        Text(minutes.toString())
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
        Text('min')
          .fontSize(12)
          .opacity(0.6)
          .fontColor($r('app.color.text_secondary'))
      }
      .alignItems(HorizontalAlign.Center)
    }
    .width(72)
    .height(72)
    .backgroundColor($r('app.color.search_background'))
    .margin(4)
    .stateEffect(true)
    .onClick(() => {
      EventBus.send('SetTimer', minutes)
    })
  }

  build() {
    Column() {
      Row() {
        Text('定时关闭')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        if (this.remainingTime !== '') {
          Toggle({ type: ToggleType.Switch, isOn: true })
            .onChange((isOn) => {
              if (!isOn) {
                EventBus.send('SetTimer', null)
              }
            })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ top: 8, bottom: 16 })

      if (this.remainingTime) {
        Text(this.remainingTime)
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .margin({ bottom: 16 })
      }

      // 预设时间选项
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
        ForEach(this.timeOptions, (minutes: number) => {
          this.TimeOption(minutes)
        })
      }
      .padding({ top: 8, bottom: 8 })
      .margin({ bottom: 24 })

      // 自定义时间文本按钮
      Text('自定义时间')
        .fontColor($r('app.color.text_secondary'))
        .fontSize(14)
        .onClick(() => {
          this.dialogController.open()
        })
        .margin({ bottom: 16 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.dialog_background'))
  }
}