import { StyleConstants } from "../common/Constant";
import { PersonFavorite } from "../component/PersonFavorite";
import { AccountProfile } from "../type/Account";
import { Login } from "./Login";
import { PreferencesUtil } from "../common/PreferenceUtil";
import { cover } from "../common/APIHelper";
import { Playlist, UserPlaylistResponse } from "../type/Playlist";
import { PlaylistCard as PlaylistCardComponent } from "../component/PlayListCard";
import { router } from "@kit.ArkUI";

@Component
export struct Library {
  @StorageLink("ValidCookie") validCookie: boolean = false;
  @StorageLink("Profile") profile: AccountProfile | null = null
  @StorageLink("UserPlayListDetail") userPlayListDetail: UserPlaylistResponse | null = null

  @Builder
  Avatar(profile: AccountProfile) {
    Image(cover(profile.avatarUrl, 64))
      .width(40)
      .height(40)
      .borderRadius(8)
      .objectFit(ImageFit.Cover)
      .bindMenu([
        {
          value: '退出登录',
          action: () => {
            PreferencesUtil.delete("account")
            PreferencesUtil.delete("profile")
            PreferencesUtil.delete("cookie")
            PreferencesUtil.delete("signAt")
            AppStorage.set('ValidCookie', false)
            AppStorage.set('Profile', null)
          }
        },
        {
          value: '软件设置',
          action: () => {
            router.pushUrl({
              url: "pages/Setting"
            })
          }
        },
        {
          value: '关于软件',
          action: () => {
            router.pushUrl({
              url: "pages/About"
            })
          }
        },
      ])
  }

  build() {
    if (!this.validCookie || !this.profile) {
      Login()
    } else {
      Column() {
        // 顶部标题栏
        Row({ space: 8 }) {
          Row() {
            Text(`${this.profile.nickname}的音乐库`)
              .font({ size: 20, weight: StyleConstants.FONT_WEIGHT_SEVEN })
          }
          .padding({ left: 16, right: 16 })
          .justifyContent(FlexAlign.SpaceBetween)

          Row() {
            this.Avatar(this.profile)
          }.padding({ left: 16, right: 16 })
        }
        .width(StyleConstants.FULL_WIDTH)
        // .backgroundImage($r("app.media.ic_background"))
        // .backdropBlur(30)
        .expandSafeArea()
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({
          left: 16,
          right: 16,
          top: 8,
          bottom: 8
        })

        // 可滚动内容区域
        List({ space: 16 }) {
          // 我喜欢的音乐
          ListItem() {
            Row() { // 添加 Row 容器
              PersonFavorite({
                count: this.userPlayListDetail?.playlist[0]?.trackCount ?? 0
              })
            }
            .width(StyleConstants.FULL_WIDTH) // 设置宽度
            .justifyContent(FlexAlign.Center) // 水平居中
            .onClick(() => {
              AppStorage.setOrCreate("CollectionId", this.userPlayListDetail?.playlist[0].id)
              router.pushUrl({
                url: "pages/Collection",
              })
            })
          }

          // 创建的歌单
          ListItem() {
            Grid() {
              ForEach(this.userPlayListDetail?.playlist.slice(1), (item: Playlist, index) => {
                GridItem() {
                  PlaylistCardComponent({
                    title: item.name,
                    coverUrl: cover(item.coverImgUrl, 100),
                    creator: item.creator.nickname,
                    index,
                    count: item.trackCount
                  })
                }.onClick(() => {
                  AppStorage.setOrCreate("CollectionId", item.id)
                  router.pushUrl({
                    url: "pages/Collection",
                  })
                })
              }, (item: Playlist) => `playlist-${item.id}}`)
            }
            .width('100%')
            .columnsTemplate(`repeat(1, 1fr)`)
            .columnsGap(8)
            .rowsGap(8)
            .padding({ left: 8, right: 8, bottom: 16 })
          }
        }
        .width(StyleConstants.FULL_WIDTH)
        .layoutWeight(1) // 占据剩余空间
        .edgeEffect(EdgeEffect.Spring) // 添加回弹效果
        .scrollBar(BarState.Off)
      }
      .width(StyleConstants.FULL_WIDTH)
      .height(StyleConstants.FULL_HEIGHT)
    }
  }
}