import { preferences } from "@kit.ArkData";
import { Context } from "@kit.AbilityKit";
import { hilog } from "@kit.PerformanceAnalysisKit";
import { BusinessError } from "@kit.BasicServicesKit";
import App from "@system.app";

const LOG_TAG = 'PREFERENCE'
const KEY_APP_FONT_SIZE = 'appFontSize'
const KEY_APP_NOTIFY = 'appNotify'

/**
 * Preference 首选项工具类
 */
export class PreferenceUtils {
  preference?: preferences.Preferences
  // 判断是否支持新的 GSKV 模式
  isSupportGSKV: boolean = false

  getSettingPreference(context: Context) {
    this.isSupportGSKV = preferences.isStorageTypeSupported?.(preferences.StorageType?.GSKV) ?? false
    // 注：确定存储模式后不可切换
    this.preference = preferences.getPreferencesSync(context, { name: 'SettingPreferences', storageType: this.isSupportGSKV ? preferences.StorageType?.GSKV : preferences.StorageType?.XML || 0 })
    hilog.info(0x0000, LOG_TAG, 'Preference create success')

    let observer = (key: string) => {
      hilog.info(0x0000, LOG_TAG, `Preference ${key} has changed`)
    }

    this.preference.on('change', observer)
  }

  getAppFontSizeOffset() {
    let fontSizeOffset = 0
    fontSizeOffset = this.preference?.getSync(KEY_APP_FONT_SIZE, fontSizeOffset) as number
    return fontSizeOffset
  }

  getAppNotify() {
    let appNotify = false
    appNotify = this.preference?.getSync(KEY_APP_NOTIFY, appNotify) as boolean
    return appNotify
  }

  syncAppFontSizeChange(fontSizeOffset: number) {
    this.preference?.putSync(KEY_APP_FONT_SIZE, fontSizeOffset)
    // 如果是 GSKV 模式，不需要调用 flush 方法，即可实时与持久化文件同步
    if (this.isSupportGSKV) return

    this.preference?.flush((err: BusinessError) => {
      if (err) {
        hilog.error(0x0000, LOG_TAG, `Failed to flush, error code: ${err.code}, message: ${err.message}`)
        return
      }
      hilog.info(0x0000, LOG_TAG, 'Flush success')
    })
  }

  syncAppNotifyChange(appNotify: boolean) {
    this.preference?.putSync(KEY_APP_NOTIFY, appNotify)
    if (this.isSupportGSKV) return

    this.preference?.flush((err: BusinessError) => {
      if (err) {
        hilog.error(0x0000, LOG_TAG, `Failed to flush, error code: ${err.code}, message: ${err.message}`)
        return
      }
      hilog.info(0x0000, LOG_TAG, 'Flush success')
    })
  }

  /**
   * 检查 Key 是否存在
   */
  isKeyExist() {
    let isKeyExist:boolean = false

    try {
      isKeyExist = this.preference?.hasSync(KEY_APP_FONT_SIZE) as boolean
    } catch (err) {
      hilog.error(0x0000, LOG_TAG, `Has the value failed with err: ${err}`)
    }

    return isKeyExist
  }

  /**
   * 销毁 Preference 实例
   */
  clearPreferences(context: Context) {
    preferences.deletePreferences(context, 'SettingPreferences', (err: BusinessError) => {
      if (err) {
        hilog.error(0x0000, LOG_TAG, `Failed to delete preference, error code: ${err.code}, message: ${err.message}}`)
        return
      }
      hilog.info(0x0000, LOG_TAG, `Delete preference success`)
    })
  }
}

export default new PreferenceUtils()