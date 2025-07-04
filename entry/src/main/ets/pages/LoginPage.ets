/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { promptAction } from '@kit.ArkUI';
import { rcp } from '@kit.RemoteCommunicationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ConnectionUtils } from '../utils/connectionUtils';
import { connection } from '@kit.NetworkKit';

@Extend(TextInput)
function inputStyle() {
  .placeholderColor('#99182431')
  .height('45vp')
  .fontSize('18fp')
  .backgroundColor('#F1F3F5')
  .width('328vp')
  .margin({ top: 12 })
  .border({
    style: {
      bottom: BorderStyle.Solid,
    },
    width: {
      bottom: 1,
    },
    color: {
      bottom: '#33182431'
    },
    radius: {
      bottomRight: 0,
      bottomLeft: 0,
    }
  })
}

@Extend(Line)
function lineStyle() {
  .width('328vp')
  .height('1vp')
  .backgroundColor('#33182431')
}

@Extend(Text)
function blueTextStyle() {
  .fontColor('#007DFF')
  .fontSize('14fp')
  .fontWeight(FontWeight.Medium)
}

/**
 * Login page
 */
interface GeneratedTypeLiteralInterface_1 {
  src: Resource;
  handler?: Function;
}

@Entry
@Component
struct LoginPage {
  @State account: string = '';
  @State password: string = '';
  @State isShowProgress: boolean = false;
  private timeOutId: number = -1;
  pathStack: NavPathStack = new NavPathStack();

  session = rcp.createSession()

  @Builder
  imageButton($$: GeneratedTypeLiteralInterface_1) {
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      Image($$.src)
    }
    .height('48vp')
    .width('48vp')
    .backgroundColor('#F1F3F5')
    .onClick(() => {
      $$.handler?.()
    })
  }

  aboutToDisappear() {
    clearTimeout(this.timeOutId);
    this.timeOutId = -1;
  }

  build() {
    Navigation(this.pathStack) {
      Scroll() {
        RelativeContainer() {
          Column() {
            Image($r('app.media.logo'))
              .width('78vp')
              .height('78vp')
              .margin({
                top: '150vp',
                bottom: '8vp'
              })
            Text($r('app.string.login_page'))
              .fontSize('24fp')
              .fontWeight(FontWeight.Medium)
              .fontColor('#182431')
            Text($r('app.string.login_more'))
              .fontSize('16fp')
              .fontColor('#99182431')
              .margin({
                bottom: '30vp',
                top: '8vp'
              })

            TextInput({ placeholder: $r('app.string.account') })
              .maxLength(11)
              .type(InputType.Number)
              .inputStyle()
              .onChange((value: string) => {
                this.account = value;
              })

            TextInput({ placeholder: $r('app.string.password') })
              .maxLength(8)
              .type(InputType.Password)
              .inputStyle()
              .onChange((value: string) => {
                this.password = value;
              })

            Row() {
              Text($r('app.string.message_login'))
                .blueTextStyle()
              Text($r('app.string.forgot_password'))
                .blueTextStyle()
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('328vp')
            .margin({ top: '8vp' })

            Button($r('app.string.login'), { type: ButtonType.Capsule })
              .width('328vp')
              .height('40vp')
              .fontSize('16fp')
              .fontWeight(FontWeight.Medium)
              .backgroundColor('#007DFF')
              .margin({
                top: '48vp',
                bottom: '12vp'
              })
              .onClick(() => {
                this.login(true);
              })
            Text($r('app.string.register_account'))
              .fontColor('#007DFF')
              .fontSize('16fp')
              .fontWeight(FontWeight.Medium)

            Blank()
            Text($r('app.string.other_login_method'))
              .fontColor('#838D97')
              .fontSize('12fp')
              .fontWeight(FontWeight.Medium)
              .margin({
                top: '50vp',
                bottom: '12vp'
              })
            Row({ space: 44 }) {
              this.imageButton({ src: $r('app.media.login_method1'), handler: () => {
                this.getAllNets()
                this.getDefaultNetInfo()
              } })
              this.imageButton({ src: $r('app.media.login_method2'), handler: this.getDefaultNetAccessInternet })
              this.imageButton({ src: $r('app.media.login_method3'), handler: this.getIPAddressByUseDefaultNet })
            }
            .margin({ bottom: '16vp' })
          }
            .height('100%')
            .width('100%')
            .padding({
              left: '12vp',
              right: '12vp',
              bottom: '24vp'
            })

          if (this.isShowProgress) {
            Stack() {
              Column() {
                LoadingProgress()
                  .color('#182431')
                  .width('30vp')
                  .height('30vp')

                Text('登录中...')
                  .fontSize(13)
              }
              .alignItems(HorizontalAlign.Center)
              .justifyContent(FlexAlign.Center)
              .padding(20)
              .backgroundColor(Color.White)
              .borderRadius(16)
            }
            .width('100%')
            .height('100%')
            .alignRules({
              top: { anchor: "__container__", align: VerticalAlign.Top },
              left: { anchor: "__container__", align: HorizontalAlign.Start }
            })
            .backgroundColor('rgba(0, 0, 0, 0.05)')
          }
        }
      }
    }
    .backgroundColor('#F1F3F5')
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .hideToolBar(true)
  }

  /**
   * 模拟登录
   * @param result
   */
  login(result: boolean): void {
    if (this.account === '' || this.password === '') {
      promptAction.showToast({
        message: $r('app.string.input_empty_tips')
      })
    } else {
      this.isShowProgress = true;
      if (this.timeOutId === -1) {
        this.timeOutId = setTimeout(() => {
          this.isShowProgress = false;
          this.timeOutId = -1;
          this.pathStack.pushPathByName('MainPage', null);
        }, 2000);
      }
    }
  }

  /**
   * 登录请求
   */
  handleLoginRequest():void {
    const url = 'https://gateway.23mofang.com'

    const postContent: rcp.RequestContent = {
      fields: {
        phone: this.account,
        password: this.password,
      }
    }


    this.session.post(url, postContent)
      .then((response) => {
        hilog.info(0x0000, 'LOGIN SUCCESS', JSON.stringify(response))
      })
      .catch((err: BusinessError) => {
        hilog.info(0x0000, 'LOGIN', JSON.stringify(err))
      })
  }

  /**
   * 网络变化处理
   */
  handleUseLoginRequest():void {
    const connectionUtil:ConnectionUtils = new ConnectionUtils()
    connectionUtil.netConnection.on("netAvailable", async (netHandle: connection.NetHandle) => {
      // 默认网络切换时，触发 netAvailable 事件，在此事件回调内重新建立 session
      this.session.close()
      this.session = rcp.createSession()

      this.handleLoginRequest()
    })

    try {
      // 调用网络请求之前，先调用 register
      connectionUtil.netConnection.register(() => {
      });
      this.handleLoginRequest()
    } catch (e) {
      console.error(e.code.toString());
    }
  }

  /**
   * 获取所有网络列表
   */
  getAllNets() {
    connection.getAllNets()
      .then((data: connection.NetHandle[]) => {
        hilog.info(0x0000, 'LOGIN GET ALL NETS', JSON.stringify(data))
      })
  }

  /**
   * 获取默认网络信息
   */
  getDefaultNetInfo() {
    connection.getDefaultNet()
      .then((data: connection.NetHandle) => {
        if (data.netId === 0) {
          //   netId 为 0，即无默认网络
          hilog.info(0x0000, 'LOGIN GET DEFAULT NET', 'NOT EXIST')
          return
        }

        if (data) {
          hilog.info(0x0000, 'LOGIN GET DEFAULT NET', JSON.stringify(data))

          // 获取对应网络的详细信息
          connection.getNetCapabilities(data)
            .then((res: connection.NetCapabilities) => {
              hilog.info(0x0000, 'LOGIN GET DEFAULT NET CAPABILITIES', JSON.stringify(res))

              // 获取网络类型
              const bearerTypes: Set<number> = new Set(res.bearerTypes)
              const enum bearerTypeEnum {
                BEARER_CELLULAR = 0,
                BEARER_WIFI = 1,
                BEARER_ETHERNET = 3
              }

              for (let item of Array.from(bearerTypes.values())) {
                if (item === bearerTypeEnum.BEARER_CELLULAR) {
                  hilog.info(0x0000, 'LOGIN GET DEFAULT NET BEARER TYPE', 'CELLULAR')
                } else if (item === bearerTypeEnum.BEARER_WIFI) {
                  hilog.info(0x0000, 'LOGIN GET DEFAULT NET BEARER TYPE', 'WIFI')
                } else if (item === bearerTypeEnum.BEARER_ETHERNET) {
                  hilog.info(0x0000, 'LOGIN GET DEFAULT NET BEARER TYPE', 'ETHERNET')
                }
              }

              //   获取网络具体能力
              const networkCaps: Set<number> = new Set(res.networkCap)
              const enum Caps {
                NET_CAPABILITY_MMS = 0, // 可访问运营商多媒体短信服务
                NET_CAPABILITY_NOT_METERED = 11, // 网络流量未计费
                NET_CAPABILITY_INTERNET = 12, // 网络可访问因特网
                NET_CAPABILITY_NOT_VPN = 15, // 网络未使用 VPN
                NET_CAPABILITY_VALIDATED = 16 // 网络已经过验证
              }

              for (let item of Array.from(networkCaps.values())) {
                if (item === Caps.NET_CAPABILITY_MMS) {
                  hilog.info(0x0000, 'LOGIN GET DEFAULT NET CAP', 'MMS')
                } else if (item === Caps.NET_CAPABILITY_NOT_METERED) {
                  hilog.info(0x0000, 'LOGIN GET DEFAULT NET CAP', 'NOT METERED')
                } else if (item === Caps.NET_CAPABILITY_INTERNET) {
                  hilog.info(0x0000, 'LOGIN GET DEFAULT NET CAP', 'INTERNET')
                } else if (item === Caps.NET_CAPABILITY_NOT_VPN) {
                  hilog.info(0x0000, 'LOGIN GET DEFAULT NET CAP', 'NOT VPN')
                } else if (item === Caps.NET_CAPABILITY_VALIDATED) {
                  hilog.info(0x0000, 'LOGIN GET DEFAULT NET CAP', 'INTERNET VALID')
                }
              }
            })

          // 获取网络连接信息
          connection.getConnectionProperties(data)
            .then((res: connection.ConnectionProperties) => {
              hilog.info(0x0000, 'LOGIN GET DEFAULT NET PROPERTIES', JSON.stringify(res))
            })
        }
      })
  }

  /**
   * 获取默认网络是否可访问因特网
   */
  getDefaultNetAccessInternet(): boolean {
    try {
      const defaultNetHandle: connection.NetHandle | null = connection.getDefaultNetSync()

      if (!defaultNetHandle || defaultNetHandle?.netId === 0) {
        return false
      }

      const defaultNetCapabilities = connection.getNetCapabilitiesSync(defaultNetHandle)
      const caps = defaultNetCapabilities.networkCap || []

      if (!caps.includes(connection.NetCap.NET_CAPABILITY_CHECKING_CONNECTIVITY) && caps.includes(connection.NetCap.NET_CAPABILITY_VALIDATED)) {
        // 网络连接不处于连通性校验状态，且验证通过
        return true
      } else {
        return false
      }
    } catch (e) {
      const err = e as BusinessError
      hilog.error(0x0000, 'LOGIN CHECK DEFAULT NET CONNECT', JSON.stringify(e))
    }
    return false
  }

  /**
   * 使用默认网络j解析域名获取 IP 地址
   */
  getIPAddressByUseDefaultNet() {
    connection.getAddressesByName("www.23mofang.com")
      .then((res: connection.NetAddress[]) => {
        hilog.info(0x0000, 'LOGIN GET DEFAULT IP ADDRESS', JSON.stringify(res))
      })
  }
}