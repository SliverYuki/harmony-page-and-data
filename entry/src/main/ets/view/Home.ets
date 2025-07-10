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

import mainViewModel from '../viewmodel/MainViewModel';
import ItemData from '../viewmodel/ItemData';
import { RCPUtils } from "../utils/RCPUtils";
import { rcp } from "@kit.RemoteCommunicationKit";
import { BusinessError } from "@kit.BasicServicesKit";
import { hilog } from "@kit.PerformanceAnalysisKit";
import ListResponseData from '../viewmodel/ListResponseData';
import ListInfo from '../viewmodel/ListInfo';

/**
 * Home tab content
 */
@Component
export default struct Home {
  private swiperController: SwiperController = new SwiperController();
  @State listData: ListInfo[] = []

  aboutToAppear(): void {
    this.getListDataByRCP()
  }

  build() {
    Column() {
      Text($r('app.string.mainPage_tabTitles_home'))
        .width('100%')
        .margin({
          top: '48vp',
          bottom: '12vp'
        })
        .fontWeight(700)
        .fontSize('26fp')

      Scroll() {
        Column() {
          Swiper(this.swiperController) {
            ForEach(mainViewModel.getSwiperImages(), (img: Resource) => {
              Image(img)
                .width('100%')
                .borderRadius('16fp')
            }, (img: Resource) => JSON.stringify(img.id))
          }
          .autoPlay(true)

          Grid() {
            ForEach(mainViewModel.getFirstGridData(), (item: ItemData, index: number) => {
              GridItem() {
                Column() {
                  Image(item.img)
                    .width('40vp')
                    .height('40vp')
                  Text(item.title)
                    .fontSize('12fp')
                    .margin({ top: '4vp' })
                }
              }
            }, (item: ItemData) => JSON.stringify(item))
          }
            .backgroundImage($r('app.media.backgroundImage'))
            .backgroundImageSize({
              width: '100%',
              height: '156vp'
            })
            .columnsTemplate('1fr 1fr 1fr 1fr')
            .rowsTemplate('1fr 1fr')
            .columnsGap('8vp')
            .rowsGap('12vp')
            .margin({ top: '12vp' })
            .padding({
              top: '12vp',
              bottom: '12vp'
            })
            .height('156vp')
            .backgroundColor(Color.White)
            .borderRadius('16vp')

          List() {
            ForEach(this.listData, (item: ListInfo) => {
              ListItem() {
                Row() {
                  Image(item.indexNavPic)
                    .width('130vp')
                    .height('80vp')
                    .objectFit(ImageFit.Cover)
                    .borderRadius('8vp')
                    .margin({ right: '12vp' })

                  Column() {
                    Text(item.activityName)
                      .constraintSize({
                        maxWidth: '100%'
                      })
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .maxLines(1)
                      .fontSize('16fp')
                      .fontWeight(FontWeight.Medium)

                    Text(item.theme)
                      .constraintSize({
                        maxWidth: '100%'
                      })
                      .margin({ top: '4vp' })
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .maxLines(2)
                      .fontSize('12fp')
                      .fontWeight(FontWeight.Normal)
                      .fontColor(Color.Grey)
                  }
                    .flexShrink(1)
                    .flexGrow(1)
                    .alignItems(HorizontalAlign.Start)
                }
                  .width('100%')
                  .padding('12vp')
                  .justifyContent(FlexAlign.SpaceBetween)
              }
                .width('100%')
                .margin({ bottom: '8vp' })
                .borderRadius('16vp')
                .backgroundColor(Color.White)
                .align(Alignment.TopStart)
            }, (item: ListInfo) => item.activityName + item.indexNavPic)
          }
            .margin({ top: '8vp' })
        }
      }
      .height('660vp')
      .align(Alignment.TopStart)
      .scrollBar(BarState.Off)
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
  }

  /**
   * 使用 rcp 请求获取列表数据
   */
  async getListDataByRCP(): Promise<void> {
    const rcpUtils:RCPUtils = new RCPUtils()

    const requestUrl = 'https://svc-drcn.developer.huawei.com/community/servlet/consumer/partnerActivityService/v1/developer/activity/terminalActivities/list'

    let requestContent: rcp.RequestContent = {
      'status': '1',
      'belong': '1',
      'language': 'cn',
      'needTop': 1,
      'displayChannel': [1, 3],
      'count': 10,
      'pagestart': 1,
      'type': '1,4,5,6'
    }

    await rcpUtils.rcpSession.post(requestUrl, requestContent)
      .then((response: rcp.Response) => {
        // hilog.info(0x0000, 'MAIN PAGE GET LIST', JSON.stringify(response))
        const result = response.toJSON() as ListResponseData
        this.listData = result.value.list
      })
      .catch((err: BusinessError) => {
        hilog.info(0x0000, 'MAIN PAGE GET LIST', `error code: ${err.code}, info: ${JSON.stringify(err)}`)
      })
      .finally(() => {
        // 请求完毕后，关闭会话，释放资源
        rcpUtils.destroySession()
      })
  }
}
