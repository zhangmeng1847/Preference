import FontSizeDialog from '../pages/FontSizeDialog'
import PreferenceUtil from '../utils/MyPreferenceUtil'

@Entry
@Component
struct Index {
  @State message: string = '用户首选项demo'
  @Provide fontSize: number = 16

  dialogController:CustomDialogController = new CustomDialogController({
    builder:FontSizeDialog(),
    alignment:DialogAlignment.Bottom,
    offset:{dx:0, dy:-24}
  })

  async  aboutToAppear(){
    //获取本地存储的数据
    this.fontSize = await PreferenceUtil.getPreferenceValue('MyPreferences', 'FontSize', 16) as number
  }

  build() {
    Column(){
      this.PageNavBar()
      this.PageContent()
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  PageNavBar(){
    Row(){
      //标题
      Text(this.message)
        .fontSize(25)
        .fontWeight(FontWeight.Bold)
        .height(80)
      //设置按钮
      Image($r('app.media.settings'))
        .width(30)
        .onClick(() => {
          this.dialogController.open()
        })
    }
    .justifyContent(FlexAlign.SpaceEvenly)
    .backgroundColor('#f1f2f3')
    .width('100%')
  }

  @Builder
  PageContent(){
    Row(){
      Text('这是一段测试字体')
        .fontSize(this.fontSize)
        .textAlign(TextAlign.Center)
        .width('100%')
    }
    .width('100%')
    .layoutWeight(1)
  }
}