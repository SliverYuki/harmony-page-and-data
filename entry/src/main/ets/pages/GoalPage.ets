import { GoalItem } from '../viewmodel/GoalItem'

@Builder
export function GoalPageBuilder() {
  GoalPage()
}

@Component
export struct GoalPage {
  @State plansSet: Array<boolean> = []
  @State plan: GoalItem = new GoalItem()
  @State durationSelectOptions: Array<SelectOption> = []
  @State durationSet: number[] = []
  @State currentDuration: number | undefined = undefined
  @State currentStatus: boolean | undefined = undefined
  @State isUpdateNow: boolean = false
  @State isInsertNow: boolean = false
  @State currentNumber: number = 0
  @State currentPlan: GoalItem = new GoalItem()
  @State duration: number = 0
  @State status: boolean = false
  @State addSportID: number = 0
  @State addDuration: number = 0
  @State addStatus: boolean = false

  build() {
    NavDestination() {
      Column() {
        Column() {

        }
      }
        .width('100%')
        .height('100%')
        .padding({ left: '12vp', right: '12vp' })
        .justifyContent(FlexAlign.SpaceBetween)
    }
    .backgroundColor('#F1F3F5')
    .hideTitleBar(true)
  }
}