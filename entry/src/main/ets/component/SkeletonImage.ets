@Component
export struct SkeletonImage {
  @Prop imageUrl: string
  @Prop imageAlt: string  = ""
  @Prop imageWidth: string = '100%'
  @Prop imageRatio: number = 1
  @Prop imageRadius: number | string = 0
  @State isLoading: boolean = true

  build() {
    Stack() {
      // 骨架屏
      if (this.isLoading) {
        Column() {
          Row()
            .width(this.imageWidth)
            .aspectRatio(this.imageRatio)
            .borderRadius(this.imageRadius)
            .backgroundColor('#f0f0f0') // 骨架屏背景色
            .animation({
              duration: 1500,
              tempo: 1.0,
              delay: 0,
              curve: Curve.Linear,
              playMode: PlayMode.Alternate,
              iterations: -1
            })
        }
      }
      
      // 实际图片
      Image(this.imageUrl)
        .alt(this.imageAlt)
        .width(this.imageWidth)
        .aspectRatio(this.imageRatio)
        .borderRadius(this.imageRadius)
        .objectFit(ImageFit.Cover)
        .onComplete(() => {
          this.isLoading = false
        })
        .onError(() => {
          this.isLoading = false
        })
    }
  }
}