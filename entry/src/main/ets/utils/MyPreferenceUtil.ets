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

  //可自行完成：移除指定名称的preferences对象中存储的所有数据的函数封装
  //可自行完成：获取指定名称的preferences对象中存储的所有数据的函数封装
  //可自行完成：移除指定名称的preferences对象函数封装
}

const preferencesUtil = new MyPreferenceUtil()
export default preferencesUtil as MyPreferenceUtil