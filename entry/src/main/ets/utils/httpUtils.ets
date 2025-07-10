import { http } from '@kit.NetworkKit'

/**
 * http 工具类
 */

export class HttpUtils {
  httpRequest: http.HttpRequest

  constructor() {
    this.httpRequest = http.createHttp()
  }

  destroyHttpRequest() {
    this.httpRequest.destroy()
  }
}