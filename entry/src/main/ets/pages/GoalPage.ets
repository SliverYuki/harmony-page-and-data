import { GoalItem } from '../viewmodel/GoalItem'
import RDBStoreUtils from '../utils/RDBStoreUtils'
import { JSON } from '@kit.ArkTS'
import { hilog } from '@kit.PerformanceAnalysisKit'

@Builder
export function GoalPageBuilder() {
  GoalPage()
}

@Component
export struct GoalPage {
  @State plansSet: Array<GoalItem> = []
  @State plan: GoalItem = new GoalItem()
  @State durationSelectOptions: Array<SelectOption> = []
  @State durationSet: number[] = []
  @State currentDuration: number | undefined = undefined
  @State currentStatus: boolean | undefined = undefined
  @State statusSelectOptions: Array<SelectOption> = []
  @State isUpdateNow: boolean = false
  @State isInsertNow: boolean = false
  @State currentIndex: number = 0
  @State currentPlan: GoalItem = new GoalItem()
  @State duration: number = 0
  @State status: boolean = false
  @State addSportID: number = 0
  @State addDuration: number = 0
  @State addStatus: boolean = false

  async aboutToAppear() {
    RDBStoreUtils.createSportTable()
    RDBStoreUtils.initSportTable()
    RDBStoreUtils.createPlanTable()

    await RDBStoreUtils.queryAllPlans()
      .then(value => {
        this.plansSet = value as Array<GoalItem>
      })

    this.resetSelectOptions()
  }

  @Builder
  insertBindSheet() {
    Column() {
      Row() {
        Text('运动名')
          .font({ size: 16, weight: 500 })
          .opacity(0.9)

        Select([
          { value: '晨跑' },
          { value: '拉伸' },
          { value: '游泳' }
        ])
          .value('晨跑')
          .width(170)
          .onSelect((index: number) => {
            this.addSportID = index
          })
      }
        .width('90%')
        .margin({ top: 16, bottom: 16 })
        .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Text('时长')
          .font({ size: 16, weight: 500 })
          .opacity(0.9)

        TextInput({ placeholder: '请输入时长(单位: 分)' })
          .width(170)
          .onChange((data: string) => {
            this.addDuration = parseInt(data)
          })
      }
        .width('90%')
        .margin({ bottom: 16 })
        .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Text('完成状态')
          .font({ size: 16, weight: 400 })
          .opacity(0.9)

        Select([
          { value: '已完成' },
          { value: '未完成' }
        ])
          .value('未完成')
          .width(170)
          .onSelect((index: number) => {
            if (index === 0) {
              this.addStatus = true
            } else {
              this.addStatus = false
            }
          })
      }
        .width('90%')
        .margin({ bottom: 16 })
        .justifyContent(FlexAlign.SpaceBetween)
    }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

    Button('提交')
      .width('90%')
      .onClick(async () => {
        await RDBStoreUtils.addPlan(this.addSportID, this.addDuration, this.addStatus)
        await RDBStoreUtils.queryAllPlans()
          .then(value => {
            this.plansSet = value
          })

        this.resetSelectOptions()
        this.isInsertNow = false
      })
  }

  @Builder
  updateBindSheet(planData: GoalItem) {
    Column() {
      Row() {
        Text('运动名')
          .font({
            size: '16fp',
            weight: 500
          })
          .opacity(0.9)
        Select([
          { value: '晨跑' },
          { value: '拉伸' },
          { value: '游泳' }
        ])
          .value(planData.sportName)
          .focusable(false)
          .width('150vp')
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('90%')
      .margin({
        top: '15vp',
        bottom: '15vp'
      })

      Row() {
        Text('时长')
          .font({
            size: '16fp',
            weight: 400
          })
          .opacity(0.9)
        TextInput({ text: planData.duration.toString() })
          .onChange((data: string) => {
            this.duration = Number.parseInt(data);
          })
          .width('150vp')
      }
      .width('90%')
      .margin({ bottom: '15vp' })
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Text('完成状态')
          .font({
            size: '16fp',
            weight: 400
          })
          .opacity(0.9)
        Select([
          { value: '已完成' },
          { value: '未完成' }
        ])
          .width('150vp')
          .value(planData.status)
          .onSelect((index: number) => {
            if (index === 0) {
              this.status = true;
            } else {
              this.status = false;
            }
          })
      }
      .width('90%')
      .margin({ bottom: '15vp' })
      .justifyContent(FlexAlign.SpaceBetween)

      Button($r('app.string.submit'))
        .width('90%')
        .onClick(async () => {
          await RDBStoreUtils.updatePlan(planData.id, this.duration, this.status);
          await RDBStoreUtils.queryAllPlans().then((value) => {
            this.plansSet = value;
          });
          this.resetSelectOptions();
          this.isUpdateNow = false;
        })
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          // 标题栏
          Text('我的目标')
            .width('100%')
            .fontSize(30)
            .fontWeight(700)
            .margin({ top: 48, bottom: 32 })

          // 操作栏
          Row() {
            Select(this.durationSelectOptions)
              .onSelect((index: number) => {
                if (index === 0) {
                  this.currentDuration = undefined
                } else {
                  this.currentDuration = this.durationSet[index - 1]
                }
              })
              .value('时长')
              .margin({ right: 25 })

            Select(this.statusSelectOptions)
              .onSelect((index => {
                if (index === 0) {
                  this.currentStatus = undefined
                } else if (index === 1) {
                  this.currentStatus = true
                } else {
                  this.currentStatus = false
                }
              }))
              .value('状态')
              .margin({ right: 25 })

            // 筛选按钮
            Button({ type: ButtonType.Circle }) {
              Image($r('app.media.sift'))
                .width(40)
                .objectFit(ImageFit.Contain)
            }
              .margin({ right: 16 })
              .width(40)
              .height(40)
              .padding(0)
              .backgroundColor(Color.Transparent)
              .onClick(async () => {
                await RDBStoreUtils.queryPlansByCondition(this.currentDuration, this.currentStatus)
                  .then(value => {
                    this.plansSet = value
                  })
              })

            // 重置按钮
            Button({ type: ButtonType.Circle }) {
              Image($r('app.media.reset'))
                .width(40)
                .objectFit(ImageFit.Contain)
            }
            .margin({ right: 16 })
            .width(40)
            .height(40)
            .padding(0)
            .backgroundColor(Color.Transparent)
            .onClick(async () => {
              await RDBStoreUtils.queryAllPlans()
                .then(value => {
                  this.plansSet = value
                })
            })
          }
            .width('100%')
            .justifyContent(FlexAlign.Start)

          // 列表
          List() {
            ForEach(this.plansSet, (item: GoalItem, index: number) => {
              ListItem() {
                Row() {
                  Column() {
                    Text(item.sportName)
                      .font({ size: 16, weight: 500 })
                      .opacity(0.9)
                    Text(item.type)
                      .font({ size: 14, weight: 400 })
                      .opacity(0.6)
                  }
                    .alignItems(HorizontalAlign.Start)
                    .margin({ left: 16 })

                  Text(item.duration + 'min')
                    .font({ size: 14, weight: 400 })
                    .opacity(0.6)

                  Text(item.status)
                    .font({ size: 14, weight: 400 })
                    .opacity(0.6)

                  // 编辑
                  Row() {
                    Button({ type: ButtonType.Circle }) {
                      Image($r('app.media.edit'))
                        .width(40)
                        .objectFit(ImageFit.Contain)
                    }
                    .width(40)
                    .height(40)
                    .margin({ right: 12 })
                    .padding(0)
                    .backgroundColor(Color.Transparent)
                    .onClick(() => {
                      this.currentPlan = item
                      this.currentIndex = index
                      this.isUpdateNow = true
                    })

                    // 删除
                    Button({ type: ButtonType.Circle }) {
                      Image($r('app.media.delete'))
                        .width(40)
                        .objectFit(ImageFit.Contain)
                    }
                    .width(40)
                    .height(40)
                    .padding(0)
                    .backgroundColor(Color.Transparent)
                    .onClick(() => {
                      this.getUIContext().showAlertDialog(
                        {
                          message: '确定删除该计划吗？',
                          autoCancel: true,
                          alignment: DialogAlignment.Bottom,
                          gridCount: 4,
                          offset: { dx: 0, dy: -20 },
                          primaryButton: {
                            value: '取消',
                            action: () => {
                              hilog.info(0x0000, 'GOAL', 'Callback when the first button is clicked');
                            }
                          },
                          secondaryButton: {
                            enabled: true,
                            defaultFocus: true,
                            style: DialogButtonStyle.HIGHLIGHT,
                            value: '删除',
                            action: async () => {
                              await RDBStoreUtils.deletePlan(item.id);
                              this.resetSelectOptions();
                              await RDBStoreUtils.queryAllPlans().then((value) => {
                                this.plansSet = value;
                              });
                            }
                          },
                          cancel: () => {
                            hilog.info(0x0000, 'GOAL', 'Closed callbacks');
                          },
                          onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
                            if (dismissDialogAction.reason == DismissReason.PRESS_BACK) {
                              dismissDialogAction.dismiss();
                            }
                            if (dismissDialogAction.reason == DismissReason.TOUCH_OUTSIDE) {
                              dismissDialogAction.dismiss();
                            }
                          }
                        }
                      )
                    })
                  }
                }
                  .width('100%')
                  .height('100%')
                  .justifyContent(FlexAlign.SpaceBetween)
              }
                .width('100%')
                .height(60)
            }, (item: GoalItem) => JSON.stringify(item))
          }
            .width('100%')
            .height('auto')
            .divider({
              strokeWidth: 1,
              color: '#1a000000',
              startMargin: 16,
              endMargin: 16,
            })
            .bindSheet(this.isUpdateNow, this.updateBindSheet(this.currentPlan), {
              height: '320vp',
              title: { title: $r('app.string.bind_title') },
              onDisappear: () => {
                this.isUpdateNow = false;
              }
            })
        }

        Button('新建计划')
          .width('100%')
          .margin({ bottom: 32 })
          .onClick(() => {
            this.isInsertNow = true
          })
          .bindSheet(this.isInsertNow, this.insertBindSheet(), {
            height: 320,
            title: { title: '创建计划' },
            onDisappear: () => {
              this.isInsertNow = false
            }
          })
      }
        .width('100%')
        .height('100%')
        .padding({ left: '12vp', right: '12vp' })
        .justifyContent(FlexAlign.SpaceBetween)
    }
    .backgroundColor('#F1F3F5')
    .hideTitleBar(true)
  }

  async resetSelectOptions() {
    await RDBStoreUtils.queryAllPlansDuration()
      .then(value => {
        this.durationSet = value
      })

    this.durationSelectOptions = [{ value: '全部' }]
    this.durationSet.forEach(el => {
      this.durationSelectOptions.push({ value: el + 'min' })
    })

    this.statusSelectOptions = [
      { value: "全部" },
      { value: '已完成' },
      { value: '未完成' }
    ]

    this.currentDuration = undefined
    this.currentStatus = undefined
  }
}