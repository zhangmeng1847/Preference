# Preferences
该代码仓库主要实现HarmonyOS中Preferences实现本地持久化的使用场景，通过封装Preferences来实现手机应用中常见的轻量级存储
### 数据持久化的概念
> 将内存中的数据通过文件或数据库的形式保存到设备上。内存中的数据形态通常是任意的数据结构或数据对象，存储介质上的数据形态可能是文本、数据库、二进制文件等。

HarmonyOS系统支持典型的存储数据形态，包括：用户首选项、键值型数据库、关系型数据库，开发者可以结合业务开发需要，选择合适的数据持久化方式，下方是不同持久化方式的特点介绍：
> -   用户首选项（Preferences）：为应用提供Key-Value键值型的数据处理能力，通常用于保存应用的配置信息。数据通过文本的形式保存在设备中，应用使用过程中会将文本中的数据全量加载到内存中，所以访问速度快、效率高，但不适合需要存储大量数据的场景。
> -   关系型数据库（RelationalStore）：一种关系型数据库，以行和列的形式存储数据，广泛用于应用中的关系型数据的处理，包括一系列的增、删、改、查等接口，开发者也可以运行自己定义的SQL语句来满足复杂业务场景的需要。
> -   键值型数据库（KV-Store）：一种非关系型数据库，其数据以“键值”对的形式进行组织、索引和存储，其中“键”作为唯一标识符。适合很少数据关系和业务关系的业务数据存储，同时因其在分布式场景中降低了解决数据库版本兼容问题的复杂度，和数据同步过程中冲突解决的复杂度而被广泛使用。相比于关系型数据库，更容易做到跨设备跨版本兼容。
### 一、用户首选项实现数据持久化_Preference
#### 1. 用户首选项的运行机制介绍
![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b831a6802431425580043fe780224d96~tplv-k3u1fbpfcp-jj-mark:0:0:0:0:q75.image#?w=1670&h=1086&s=660693&e=png&b=212121)
1. 用户应用程序通过ArkTS接口获取到用户首选项的实例对象preference，通过该对象读写数据
2. 应用首选项的持久化文件保存在应用的沙箱内部
3. 一个应用可以有多个持久化文件，每个持久化文件唯一对应到一个Preference的实例
4. 注意Preference实例在使用前应先创建并初始化，系统会通过静态容器将该实例存储在内存中
#### 2. 用户首选项的使用步骤
##### 2.1 导入首选项模块

```ts
import dataPreferences from '@ohos.data.preferences';
```
##### 2.2 获取首选项实例，读取指定的持久化文件，两种实现方式效果类似
方式一：无返回值，在callback回调中获取preference实例，然后进行数据的操作

```ts
function getPreferences(context: Context, name: string, callback: AsyncCallback<Preferences>): void;
```
使用示例：

```ts
try {
   dataPreferences.getPreferences(this.context, 'myPreferences', (err, preferences) => {
        if (err) {
          console.error(`failed to get preference, Code ${err.code},message:${err.message}`)
          return
        }
        //获取实例成功，进行相关操作
   })
}catch (err){
   console.error(`failed to get preference, Code ${err.code},message:${err.message}`)
}
```
方式二：返回Promise类型对象，在promise的then回调中，preference实例以参数形式返回

```ts
function getPreferences(context: Context, name: string): Promise<Preferences>;
```
使用示例：
```ts
dataPreferences.getPreferences(this.context, 'myPreferences')
  .then(preferences => {
    //获取preferences成功，开始执行数据操作
  })
  .catch(reason => {
    //获取失败
    console.error(`failed to get preference, reason: ${reason}`)
  })
```
上述两个函数的第一个参数context表示上下文，在此函数中的实际意义是用来获取preference实例所对应的持久化文件的沙箱路径，name参数即表示当前要获取的preference实例的名称(具有唯一性)，一个应用程序中可以有多个preference实例对象，可用不同的name区分。
##### 2.3 通过preference实例对象写入（或者修改）指定键名的数据示例
使用put()方法保存数据到缓存的Preferences实例中，在写入数据时可通过preferences.has( )方法判断，当前要保存的数据的键是否已经存在，如果存在，put( )方法会修改其值。

如果仅需要在键值对不存在时新增键值对，而不修改已有键值对，需使用has( )方法检查是否存在对应键值对；如果不关心是否会修改已有键值对，则直接使用put( )方法即可。下属示例代码实现的是仅在键值对不存在时新增键值对存入对应数据，否则不做存储操作。

```ts
try {
  //先判断key为startup的数据键值对是否存在
  preferences.has('startup', function (err, val) {
    if (err) {
      console.error(`Failed to check the key 'startup'. Code:${err.code}, message:${err.message}`);
      return;
    }
    // 如果存在对应的键值对，不做put操作（根据自己的实际项目需要实现，这里只是示例）
    if (val) {
      console.info("The key 'startup' is contained.");
    } else {
      console.info("The key 'startup' does not contain.");
      // 此处以此键值对不存在时写入数据为例
      try {
        // 通过put函数写入键值对数据{'startup':'auto'}
        preferences.put('startup', 'auto', (err) => {
          if (err) {
            console.error(`Failed to put data. Code:${err.code}, message:${err.message}`);
            return;
          }
          console.info('Succeeded in putting data.');
        })
      } catch (err) {
        console.error(`Failed to put data. Code: ${err.code},message:${err.message}`);
      }
    }
  })
} catch (err) {
  console.error(`Failed to check the key 'startup'. Code:${err.code}, message:${err.message}`);
}
```
注意：has( )除了上述回调函数方式调用外，也支持通过返回promise对象的方式调用，可自行尝试
##### 2.5 通过preference实例对象删除指定键名的数据
使用delete()方法删除指定键值对，示例代码如下所示

```ts
try {
  preferences.delete('startup', (err) => {
    if (err) {
      console.error(`Failed to delete the key 'startup'. Code:${err.code}, message:${err.message}`);
      return;
    }
    console.info("Succeeded in deleting the key 'startup'.");
  })
} catch (err) {
  console.error(`Failed to delete the key 'startup'. Code:${err.code}, message:${err.message}`);
}
```
注意：delete( )除了上述回调函数方式调用外，也支持通过返回promise对象的方式调用，可自行尝试
##### 2.6 将数据存入文件
应用存入数据到Preferences实例后，可以使用flush()方法实现数据持久化。示例代码如下所示：

```ts
try {
  preferences.flush((err) => {
    if (err) {
      console.error(`Failed to flush. Code:${err.code}, message:${err.message}`);
      return;
    }
    console.info('Succeeded in flushing.');
  })
} catch (err) {
  console.error(`Failed to flush. Code:${err.code}, message:${err.message}`);
}
```
flush( ) 将输入流和输出流中的缓冲进行刷新，使缓冲区中的元素即时做输入和输出，而不必等缓冲区满，调用时即马上存入文件中。一般在使用preference对象进行写入或者修改数据时调用。

注意：flush( )除了上述回调函数方式调用外，也支持通过返回promise对象的方式调用，可自行尝试
##### 2.7 订阅观察数据的变更
订阅数据变更需要指定observer作为回调方法。订阅的Key值发生变更后，当执行flush()方法时，observer被触发回调。示例代码如下所示:

```ts
let observer = function (key) {
  console.info('The key' + key + 'changed.');
}
preferences.on('change', observer);
// 修改数据产，由'auto'变为'manual'
preferences.put('startup', 'manual', (err) => {
  if (err) {
    console.error(`Failed to put the value of 'startup'. Code:${err.code},message:${err.message}`);
    return;
  }
  console.info("Succeeded in putting the value of 'startup'.");
  //此时出发订阅者时间，会执行上述observer函数
  preferences.flush((err) => {
    if (err) {
      console.error(`Failed to flush. Code:${err.code}, message:${err.message}`);
      return;
    }
    console.info('Succeeded in flushing.');
  })
})
```
注意：当订阅者观察到对应数据变化后已经出发回调时间后，如果不想多次触发，可使用 **preferences.off('change', observer)**  进行解绑订阅者
##### 2.8 移除指定名称的Preferences实例
使用deletePreferences()方法从内存中移除指定文件对应的Preferences实例，包括内存中的数据。若该Preference存在对应的持久化文件，则同时删除该持久化文件，包括指定文件及其备份文件、损坏文件。

```ts
try {
  dataPreferences.deletePreferences(this.context, 'mystore', (err, val) => {
    if (err) {
      console.error(`Failed to delete preferences. Code:${err.code}, message:${err.message}`);
      return;
    }
    console.info('Succeeded in deleting preferences.');
  })
} catch (err) {
  console.error(`Failed to delete preferences. Code:${err.code}, message:${err.message}`);
}
```
注意：deletePreferences()方法也支持通过返回promise对象的方式调用，可自行尝试，该操作为不可恢复式破坏性操作，实际开发中慎用
##### 2.9 其他注意事项
-   用户首选项支持存储的value类型有：number、string、boolean以及对应的这三种类型的数组类型
-   支持存储的key类型只能是string，key的最大长度为80个字符
-   如果Value值为string类型，建议用UTF-8编码格式，value值可以为空，value的最大长度为8192个字符，
-   建议存储的数据条数不超过一万条

#### 二、用户首选项的封装使用

```ts
import preferences from '@ohos.data.preferences';

// Preferences工具类
class MyPreferenceUtil{
  // 单个应用可包含多个Preferences实例，使用Map集合来存储Preferences对象实例
  preferenceMap: Map<string, preferences.Preferences> = new Map()

  //加载Preferences实例对象
  async loadPreference(context, name: string){
    try {
      // 加载preferences
      let preference = await preferences.getPreferences(context, name)
      this.preferenceMap.set(name, preference)
      console.log('preferencesUtilTag', `加载Preferences[${name}]成功`)
    } catch (e) {
      console.log('preferencesUtilTag', `加载Preferences[${name}]失败`, JSON.stringify(e))
    }
  }
  
  //增加（或修改）指定名称的preferences对象中存储的指定的key的数据为对应的value
  async putPreferenceValue(name: string, key: string, value: preferences.ValueType){
    if (!this.preferenceMap.has(name)) {
      console.log('preferencesUtilTag', `Preferences[${name}]尚未初始化！`)
      return
    }
    try {
      let preference = this.preferenceMap.get(name)
      // 写入数据
      await preference.put(key, value)
      // 刷盘
      await preference.flush()
      console.log('preferencesUtilTag', `保存Preferences[${name}.${key} = ${value}]成功`)
    } catch (e) {
      console.log('preferencesUtilTag', `保存Preferences[${name}.${key} = ${value}]失败`, JSON.stringify(e))
    }
  }

  //获取指定名称的preferences对象中存储的指定的key的数据
  async getPreferenceValue(name: string, key: string, defaultValue: preferences.ValueType){
    if (!this.preferenceMap.has(name)) {
      console.log('preferencesUtilTag', `Preferences[${name}]尚未初始化！`)
      return
    }
    try {
      let preference = this.preferenceMap.get(name)
      // 读数据
      let value = await preference.get(key, defaultValue)
      console.log('preferencesUtilTag', `读取Preferences[${name}.${key} = ${value}]成功`)
      return value
    } catch (e) {
      console.log('preferencesUtilTag', `读取Preferences[${name}.${key} ]失败`, JSON.stringify(e))
    }
  }

  //删除指定名称的preferences对象中存储的指定的key的数据
  async deletePreferenceValue(name: string, key: string){
    if (!this.preferenceMap.has(name)) {
      console.log('preferencesUtilTag', `Preferences[${name}]尚未初始化！`)
      return
    }
    try {
      let preference = this.preferenceMap.get(name)
      // 读数据
      if(preference.has(key)){
        let value = await preference.delete(key)
        console.log('preferencesUtilTag', `删除Preferences[${name}.${key} = ${value}]成功`)
        return value
      }else {
        console.log('preferencesUtilTag', `删除Preferences[${name}.${key} ]失败`)
      }
    } catch (e) {
      console.log('preferencesUtilTag', `删除Preferences[${name}.${key} ]失败`, JSON.stringify(e))
    }
  }
}

const preferencesUtil = new MyPreferencesUtil()
export default preferencesUtil as MyPreferencesUtil
```

#### 三、用户首选项的应用案例
具体效果如下：
[jvideo](https://www.ixigua.com/7343415884649594899)
通过用户首选项将设置的字体大小数据进行持久化缓存。
新建工程使用上述封装的PreferencesUtil工具来实现应用中字体大小配置项的持久化

第一步：在src-main-ets下创建目录utils，用于存放应用的工具类，将上述PreferencesUtil放到该目录下

第二步：在ets-pages目录下封装自定义弹窗FontSizeDialog，用Slider组件实现字体的放大和缩小的控制，注意这里使用@CustomDialog修饰符修饰自定义弹窗组件

```ts
import PreferenceUtil from '../utils/MyPreferenceUtil'

@CustomDialog
export default struct FontSizeDialog {
  controller:CustomDialogController
  //跨组件双向传值使用@Provide和@Consume
  @Consume fontSize: number
  fontSizLabel: object = {
    14: '小',
    16: '标准',
    18: '大',
    20: '特大',
  }

  build() {
    Column() {
      Text(this.fontSizLabel[this.fontSize]).fontSize(20)
      Row({ space: 5 }) {
        Text('A').fontSize(14).fontWeight(FontWeight.Bold)
        Slider({
          min: 14,
          max: 20,
          step: 2,
          value: this.fontSize
        })
          .showSteps(true)
          .trackThickness(6)
          .layoutWeight(1)
          .onChange(val => {
            // 修改字体大小
            this.fontSize = val
            // 写入Preferences
            PreferenceUtil.putPreferenceValue('MyPreferences', 'FontSize', val)
          })
        Text('A').fontSize(20).fontWeight(FontWeight.Bold)
      }.width('100%')
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#f0f0f0')
    .borderRadius(20)
    .onClick(()=>{
      this.controller.close()
    })
  }
}
```
第三步：在Index.ets（这里是举例，可在任意需要的位置使用）使用该弹窗组件，具体代码如下：

```ts
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
```
第四步：在EntryAbility.ets的模块创建的生命周期方法中初始化Preference对象

```ts
import MyPreferenceUtil from '../utils/MyPreferenceUtil'
async onCreate(want, launchParam) {
    // 初始化Preferences
    await MyPreferenceUtil.loadPreference(this.context, 'MyPreferences')
}
```



