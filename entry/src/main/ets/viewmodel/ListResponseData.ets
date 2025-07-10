import ListInfo from "./ListInfo"

class Value {
  list: ListInfo[]

  constructor(list: ListInfo[]) {
    this.list = list
  }
}

export default class ListResponseData {
  public code:string
  public value: Value

  constructor(code: string, value: Value) {
    this.code = code
    this.value = value
  }
}