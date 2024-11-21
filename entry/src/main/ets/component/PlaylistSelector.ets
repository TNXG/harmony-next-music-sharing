import { promptAction } from "@kit.ArkUI"
import { createPlayList } from "../api/Playlist"
import { cover } from "../common/APIHelper"
import { AccountProfile } from "../type/Account"
import { Playlist, UserPlaylistResponse } from "../type/Playlist"

@CustomDialog
struct CreatePlaylistDialog {
  controller: CustomDialogController
  confirm: (value: string) => void = () => {}
  cancel: () => void = () => {}
  @State value: string = ''

  build() {
    Column() {
      Text('创建歌单')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 16, top: 8 })
        .width('100%')
        .fontColor($r('app.color.text_primary'))

      TextInput({
        placeholder: '请输入歌单标题',
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
              promptAction.showToast({ message: '请输入歌单标题' })
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

@Component
export struct PlaylistSelector {
  @StorageLink("Profile") profile: AccountProfile | null = null
  @StorageLink("UserPlayListDetail") userPlayListDetail: UserPlaylistResponse | null = null
  onSelect: (id: number | string) => void = () => {}

  dialogController: CustomDialogController = new CustomDialogController({
    builder: CreatePlaylistDialog({
      cancel: () => {},
      confirm: async (value: string) => {
        const id = await createPlayList(value)
        promptAction.showToast({ message: '创建歌单成功' })
        this.onSelect(id)
      }
    }),
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -20 },
    customStyle: true,
    maskColor: $r('app.color.dialog_mask')
  })

  // 获取用户创建的歌单
  private getCreatedPlaylists(): Playlist[] {
    if (!this.userPlayListDetail?.playlist || !this.profile) return []
    return this.userPlayListDetail.playlist.filter(item =>
    item.creator.userId === this.profile?.userId
    )
  }

  @Builder
  HeaderButton() {
    Button({ type: ButtonType.Normal }) {
      Row() {
        Image($r('app.media.ic_plus'))
          .width(20)
          .height(20)
          .fillColor($r('app.color.text_primary'))
          .margin({ right: 8 })
        Text('新建歌单')
          .fontSize(16)
          .fontColor($r('app.color.text_primary'))
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
    }
    .backgroundColor(Color.Transparent)
    .height(48)
    .padding(16)
    .borderRadius(20)
    .width('100%')
    .onClick(() => {
      this.dialogController.open()
    })
  }

  @Builder
  PlaylistItem(playlist: Playlist) {
    Button({ type: ButtonType.Normal }) {
      Row() {
        Image(cover(playlist.coverImgUrl, 64))
          .width(40)
          .height(40)
          .borderRadius(4)
          .margin({ right: 12 })

        Column() {
          Text(playlist.name)
            .fontSize(16)
            .fontColor($r('app.color.text_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(`${playlist.trackCount}首`)
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
    }
    .backgroundColor(Color.Transparent)
    .height(64)
    .padding(16)
    .borderRadius(20)
    .width('100%')
    .onClick(() => {
      this.onSelect(playlist.id)
    })
  }

  build() {
    Column() {
      this.HeaderButton()

      List({ space: 8 }) {
        ForEach(this.getCreatedPlaylists(), (item: Playlist) => {
          ListItem() {
            this.PlaylistItem(item)
          }
        })
      }
      .scrollBar(BarState.Off)
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
}