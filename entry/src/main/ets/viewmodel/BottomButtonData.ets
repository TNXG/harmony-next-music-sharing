export interface  ButtonInfoModel {
  index: number ;  // 序号
  img: Resource;  // 未选中图片
  selectImg: Resource ; // 选中图片
  title: Resource; // 按钮名称
}

const buttonInfo: ButtonInfoModel[] = [
  {
    index: 0,
    img: $r("app.media.ic_star"),
    selectImg: $r("app.media.ic_star_fill"),
    title: $r('app.string.star')
  },
  {
    index: 1,
    img: $r("app.media.ic_square_grid_2x2"),
    selectImg: $r("app.media.ic_square_fill_grid_2x2"),
    title: $r('app.string.library')
  },
  {
    index: 2,
    img: $r("app.media.ic_externaldrive"),
    selectImg: $r("app.media.ic_externaldrive_fill"),
    title: $r('app.string.cached')
  }
]

export { buttonInfo }