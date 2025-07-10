import { rcp } from '@kit.RemoteCommunicationKit'
import { hilog } from '@kit.PerformanceAnalysisKit'

/**
 * @description rcp工具类
 */
export class RCPUtils {
  rcpSession: rcp.Session
  cache = new ResponseCache()

  constructor(config?: rcp.SessionConfiguration) {
    const presetInterceptors = [
      new ResponseCacheInterceptor(this.cache),
      new ResponseHeaderModifyInterceptor(),
    ]

    const tracingInstance = new HttpVerboseTracing()

    config?.interceptors?.unshift(...presetInterceptors)

    const tracingConfig = config?.requestConfiguration?.tracing
    if (tracingConfig) {
      config.requestConfiguration!.tracing = tracingInstance.getTracingConfiguration()
    }

    // this.rcpSession = rcp.createSession(config ?? {
    //   interceptors: presetInterceptors,
    //   requestConfiguration: {
    //     tracing: tracingInstance.getTracingConfiguration()
    //   }
    // })
    this.rcpSession = rcp.createSession()
  }

  destroySession() {
    this.rcpSession.close()
  }
}

/**
 * @description 拦截器
 */

// 定义响应缓存类
class ResponseCache {
  public readonly cache: Record<string, rcp.Response> = {}

  getResponse(url: string): rcp.Response {
    return this.cache[url]
  }

  setResponse(url: string, response: rcp.Response): void {
    this.cache[url] = response
  }
}

/**
 * 定义请求响应缓存的拦截器(实现 rcp 模块的 Interceptor 接口)
 * 优先使用缓存数据，缓存数据不存在时，使用请求返回
 */

class ResponseCacheInterceptor implements rcp.Interceptor {
  public readonly responseCache: ResponseCache

  constructor(responseCache: ResponseCache) {
    this.responseCache = responseCache
  }

  intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    const url = context.request.url.href
    const responseFromCache = this.responseCache.getResponse(url)

    if (responseFromCache) return Promise.resolve(responseFromCache)

    // AppStorage.setOrCreate('ReplacedInfo', `[ResponseCacheInterceptor] Request Url is ${context.request.url.href}`)

    hilog.info(0x0000, 'RCP', `[ResponseCacheInterceptor] Request Url is ${context.request.url.href}`)

    const promise = next.handle(context)

    promise.then((response) => {
      // response.statusCode;
        this.responseCache.setResponse(url, response)
    })

    return promise
  }
}

/**
 * 定义用于修改 header 的拦截器
 */
class ResponseHeaderModifyInterceptor implements rcp.Interceptor {
  async intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    const response = await next.handle(context)

    const responseToReturn: rcp.Response = {
      request: response.request,
      statusCode: response.statusCode,
      httpVersion: response.httpVersion,
      headers: {
        "content-range": response.headers['content-range']
      },
      effectiveUrl: response.effectiveUrl,
      timeInfo: response.timeInfo,
      // toJSON: () => null,
      toJSON: response.toJSON
    };

    hilog.info(0x0000, 'RCP', `[ResponseHeaderModifyInterceptor]: Response Headers modified`)

    return responseToReturn
  }
}

/**
 * 跟踪请求详细信息
 */

class HttpVerboseTracing {
  httpEventsHandler: rcp.HttpEventsHandler

  constructor() {
    this.httpEventsHandler = {
      onDataReceive: (incomingData: ArrayBuffer) => {
        hilog.info(0x0000, 'RCP', JSON.stringify(incomingData))
        return incomingData.byteLength
      },
      onHeaderReceive: (headers: rcp.RequestHeaders) => {
        hilog.info(0x0000, 'RCP', JSON.stringify(headers))
      },
      onDataEnd: () => {
        hilog.info(0x0000, 'RCP', `Data transfrom complate`)
      }
    }
  }

  getTracingConfiguration(): rcp.TracingConfiguration {
    return {
      verbose: true,
      infoToCollect: {
        incomingHeader: true,
        outgoingHeader: true,
        incomingData: true,
        outgoingData: true,
      },
      collectTimeInfo: true,
      httpEventsHandler: this.httpEventsHandler
    }
  }
}