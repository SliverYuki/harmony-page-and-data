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
import { http } from "@kit.NetworkKit";
import { HttpUtils } from "../utils/httpUtils";
import Home from "../view/Home";
import Setting from "../view/Setting";
import PreferenceUtils from '../utils/PreferenceUtils'

@Builder
export function MainPageBuilder() {
  MainPage()
}

/**
 * Main page
 */
@Component
export struct MainPage {
  @State currentIndex: number = 0;
  @State pathStack: NavPathStack = new NavPathStack();
  private tabsController: TabsController = new TabsController();

  @StorageLink('fontSizeOffset') fontSizeOffset:number = 0
  @StorageLink('appNotify') appNotify:boolean = false

  aboutToAppear(): void {
    this.fontSizeOffset = PreferenceUtils.getAppFontSizeOffset()
    this.appNotify = PreferenceUtils.getAppNotify()
  }

  @Builder
  TabBuilder(title: Resource, index: number, selectedImg: Resource) {
    Column() {
      SymbolGlyph(selectedImg)
        .fontSize('24fp')
        .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_OPACITY)
        .symbolEffect(new BounceSymbolEffect(EffectScope.WHOLE, EffectDirection.UP),
          this.currentIndex === index ? true : false)
        .fontColor(this.currentIndex === index ? ['#0a59f7'] : ['#66000000'])
      Text(title)
        .margin({ top: '4vp' })
        .fontSize(10)
        .fontWeight(500)
        .fontColor(this.currentIndex === index ? '#0a59f7' : '#66000000')
    }
    .backgroundColor('#F1F3F5')
    .justifyContent(FlexAlign.Center)
    .height('56vp')
    .width('100%')
    .onClick(() => {
      this.currentIndex = index;
      this.tabsController.changeIndex(this.currentIndex);
    })
  }

  build() {
    NavDestination() {
      Tabs({
        barPosition: BarPosition.End,
        controller: this.tabsController
      }) {
        TabContent() {
          Home({ pathStack: this.pathStack })
        }
          .padding({
            left: '12vp',
            right: '12vp'
          })
          .backgroundColor('#F1F3F5')
          .tabBar(this.TabBuilder($r('app.string.Tab_Bar_One'), 0, $r('sys.symbol.house_fill')))

        TabContent() {
          Setting()
        }
          .padding({
            left: '12vp',
            right: '12vp'
          })
          .backgroundColor('#F1F3F5')
          .tabBar(this.TabBuilder($r('app.string.Tab_Bar_Two'), 1, $r('sys.symbol.person_crop_circle_fill_1')))
      }
        .margin({ bottom: '64vp' })
        .width('100%')
        .height('100%')
        .barHeight('80vp')
        .barMode(BarMode.Fixed)
        .onChange((index: number) => {
          this.currentIndex = index;
        })
    }
      .height('100%')
      .hideTitleBar(true)
      .backgroundColor('#F1F3F5')
      .onReady((context: NavDestinationContext) => {
        this.pathStack = context.pathStack;
      })
  }

  /**
   * 使用 http 请求获取列表数据
   */
  async getListDataByHttp(): Promise<void> {
    const httpUtils = new HttpUtils()

    // 订阅响应头返回事件
    httpUtils.httpRequest.on("headersReceive", (headers) => {
      console.log("headersReceive:" + JSON.stringify(headers))
    })

    await httpUtils.httpRequest.request('/list', { method: http.RequestMethod.GET })
      .then((res: http.HttpResponse) => {

      })
      .finally(() => {
        // 请求完毕后
        // 关闭响应头返回事件监听
        httpUtils.httpRequest.off("headersReceive")
        // 销毁请求对象
        httpUtils.destroyHttpRequest()
      })
  }
}