import { AbilityStage, Want } from "@kit.AbilityKit";

export default class MyAbilityStage extends AbilityStage {
  onCreate(): void {
      //   Hap 首次加载执行，可以在此时机进行初始化操作
  }

  onAcceptWant(want: Want): string {
    // UIAbility 指定实例启动模式时触发，返回 UIAbility 的唯一标识
    return 'specifiedUIAbilityInstanceKey'
  }
}