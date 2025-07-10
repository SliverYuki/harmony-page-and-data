import { connection } from '@kit.NetworkKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { promptAction } from '@kit.ArkUI'

/**
 * @description 网络连接状态工具类
 */

export class ConnectionUtils {
  netConnection = connection.createNetConnection()

  openRegister() {
    this.netConnection.register((error: BusinessError) => {
      hilog.info(0x0000, 'NETWORK', JSON.stringify(error))
    })
  }

  registerNetworkAvailableStatus() {
    this.netConnection.on("netAvailable", () => {
      promptAction.showToast({
        message: '网络可用',
        duration: 1500,
      })
    })

    this.netConnection.on("netLost", () => {
      promptAction.showToast({
        message: '网络丢失',
        duration: 1500
      })
    })

    this.netConnection.on("netUnavailable", () => {
      promptAction.showToast({
        message: '网络不可用',
        duration: 1500
      })
    })
  }

  closeRegister() {
    this.netConnection.unregister((error: BusinessError) => {
      hilog.info(0x0000, 'NETWORK', JSON.stringify(error))
    })
  }
}