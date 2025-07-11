import { relationalStore } from '@kit.ArkData'
import { Context } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { hilog } from '@kit.PerformanceAnalysisKit'

const LOG_TAG:string = 'RDB STORE UTILS'

const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'Objective.db',
  securityLevel: relationalStore.SecurityLevel.S1
}

const CREATE_SPORTS_TABLE_SQL:string = 'CREATE TABLE IF NOT EXISTS SPORTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT ' + 'NOT NULL, TYPE TEXT NOT NULL)';

const CREATE_PLANS_TABLE_SQL: string = 'CREATE TABLE IF NOT EXISTS PLANS (ID INTEGER PRIMARY KEY AUTOINCREMENT, SPORT_ID INTEGER ' +  'NOT NULL, DURATION INTEGER NOT NULL, STATUS TEXT NOT NULL)';

const QUERY_ALL_PLANS_SQL: string = 'SELECT p.id AS ID,s.NAME AS NAME,s.type AS TYPE,p.DURATION AS DURATION,p.STATUS AS STATUS FROM SPORTS AS s ' +      'JOIN PLANS AS p WHERE s.ID = P.SPORT_ID';


export class RDBStoreUtils {
  store?: relationalStore.RdbStore

  // 获取 RDBStore 实例
  getRdbStore(context: Context) {
    relationalStore.getRdbStore(context, STORE_CONFIG, (err: BusinessError, rdbStore: relationalStore.RdbStore) => {
      this.store = rdbStore

      if (err) {
        hilog.error(0x0000, LOG_TAG, `rdbStore 初始化异常，error code: ${err.code}, messgae: ${err.message}`)
        return
      }

      hilog.error(0x0000, LOG_TAG, `rdbStore 初始化成功`)
    })
  }

  // 创建运动数据表
  createSportTable() {
    this.store?.execute(CREATE_SPORTS_TABLE_SQL)
      .then(() => {
        hilog.info(0x0000, LOG_TAG, `创建 SPORTS 表成功`)
      })
      .catch((err: BusinessError) => {
        hilog.info(0x0000, LOG_TAG, `创建 SPORTS 表失败, error code: ${err.code}, message: ${err.message}}`)
      })
  }

  // 初始化运动数据表数据
  initSportTable() {
    const sportData: relationalStore.ValuesBucket[] = [{
      'ID': 0,
      'NAME': '晨跑',
      'TYPE': '有氧运动'
    }, {
      'ID': 1,
      'NAME': '拉伸',
      'TYPE': '无氧运动'
    }, {
      'ID': 2,
      'NAME': '游泳',
      'TYPE': '有氧运动'
    }]

    this.store?.batchInsert('SPORTS', sportData)
      .then((insertRowsCount: number) => {
        hilog.info(0x0000, LOG_TAG, `batch insert success，${insertRowsCount} rows has modified`)
      })
      .catch((err: BusinessError) => {
        hilog.error(0x0000, LOG_TAG, `batch insert failed, error code: ${err.code}, message: ${err.message}`)
      })
  }

  // 创建计划数据表
  createPlanTable() {
    this.store?.execute(CREATE_PLANS_TABLE_SQL)
      .then(() => {
        hilog.info(0x0000, LOG_TAG, `创建 PLAN 表成功`)
      })
      .catch((err: BusinessError) => {
        hilog.info(0x0000, LOG_TAG, `创建 PLAN 表失败, error code: ${err.code}, message: ${err.message}}`)
      })
  }

  // 查询所有计划
  async queryAllPlans() {
    let plansSet: relationalStore.ValuesBucket[] = []
    await this.store?.querySql(QUERY_ALL_PLANS_SQL)
      .then((resultSet: relationalStore.ResultSet) => {
        // 使用 goToNextRow 获取查询结果的每一行
        while (resultSet.goToNextRow()) {
          hilog.info(0x0000, LOG_TAG, JSON.stringify(resultSet.getRow()))
          plansSet.push(resultSet.getRow())
        }
        resultSet.close()
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, LOG_TAG, `Query faild, error code: ${err.code}, message: ${err.message}`)
      })
  }

  // 编辑计划
  async updatePlan(planID: number, duration: number, status: boolean) {
    const planData: relationalStore.ValuesBucket = {
      'DURATION': duration,
      'STATUS': status ? '已完成' : '未完成'
    }

    let predicates = new relationalStore.RdbPredicates('PLANS')
    predicates.equalTo('ID', planID)

    await this.store?.update(planData, predicates, relationalStore.ConflictResolution.ON_CONFLICT_REPLACE)
      .then((updateRowsCount: number) => {
        hilog.info(0x0000, LOG_TAG, `${updateRowsCount} rows has updated`)
      })
      .catch((err: BusinessError) => {
        hilog.error(0x0000, LOG_TAG, `Update failed, error code: ${err.code}, message: ${err.message}`)
      })
  }
}