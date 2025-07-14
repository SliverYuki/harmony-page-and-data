import { relationalStore } from '@kit.ArkData'
import { Context } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { GoalItem } from '../viewmodel/GoalItem'

const LOG_TAG:string = 'RDB STORE UTILS'

const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'Objective.db',
  securityLevel: relationalStore.SecurityLevel.S1
}

const CREATE_SPORTS_TABLE_SQL:string = 'CREATE TABLE IF NOT EXISTS SPORTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT' + ' NOT NULL, TYPE TEXT NOT NULL)';

const CREATE_PLANS_TABLE_SQL: string = 'CREATE TABLE IF NOT EXISTS PLANS (ID INTEGER PRIMARY KEY AUTOINCREMENT, SPORT_ID INTEGER ' + 'NOT NULL, DURATION INTEGER NOT NULL, STATUS TEXT NOT NULL)';

const QUERY_ALL_PLANS_SQL: string = 'SELECT p.id AS ID,s.NAME AS NAME,s.type AS TYPE,p.DURATION AS DURATION,p.STATUS AS STATUS FROM SPORTS AS s ' + ' JOIN PLANS AS p WHERE s.ID = P.SPORT_ID';

const QUERY_PLANS_BY_DURATION_SQL: string =
  'SELECT p.id AS ID,s.NAME AS NAME,s.type AS TYPE,p.DURATION AS DURATION,p.STATUS AS STATUS FROM SPORTS AS s' +
    ' JOIN PLANS AS p WHERE s.ID = P.SPORT_ID AND p.DURATION = ';

const QUERY_PLANS_BY_STATUS_SQL: string =
  'SELECT p.id AS ID,s.NAME AS NAME,s.type AS TYPE,p.DURATION AS DURATION,p.STATUS AS STATUS FROM SPORTS AS s' +
    ' JOIN PLANS AS p WHERE s.ID = P.SPORT_ID AND p.STATUS = "';

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
    let plansSet: GoalItem[] = []
    await this.store?.querySql(QUERY_ALL_PLANS_SQL)
      .then((resultSet: relationalStore.ResultSet) => {
        // 使用 goToNextRow 获取查询结果的每一行
        while (resultSet.goToNextRow()) {
          hilog.info(0x0000, LOG_TAG, JSON.stringify(resultSet.getRow()))
          // 获取详细字段时，需要使用类型转换

          const id: number = resultSet.getValue(resultSet.getColumnIndex('ID')) as number
          const name:string = resultSet.getValue(resultSet.getColumnIndex('NAME')) as string
          const type:string = resultSet.getValue(resultSet.getColumnIndex('TYPE')) as string
          const duration:number = resultSet.getValue(resultSet.getColumnIndex('DURATION')) as number
          const status:string = resultSet.getValue(resultSet.getColumnIndex('STATUS')) as string

          plansSet.push(new GoalItem(id, name, type, duration, status))
        }
        resultSet.close()
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, LOG_TAG, `Query faild, error code: ${err.code}, message: ${err.message}`)
      })
    return plansSet
  }

  // 查询所有计划中的时长
  async queryAllPlansDuration() {
    const durationSet: Array<number> = []

    await this.store?.querySql(QUERY_ALL_PLANS_SQL)
      .then(resultSet => {
        while (resultSet.goToNextRow()) {
          hilog.info(0x0000, LOG_TAG, JSON.stringify(resultSet.getRow()))

          const duration: number = resultSet.getValue(resultSet.getColumnIndex('DURATION')) as number
          durationSet.push(duration)
        }

        resultSet.close()
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, LOG_TAG, `Query Durations faild, error code: ${err.code}, message: ${err.message}`)
      })

    return durationSet
  }

  // 根据条件查询计划
  async queryPlansByCondition(duration: number | undefined, status: boolean | undefined) {
    let plansSet: GoalItem[] = []

    // 根据参数构建 SQL 语句，添加 duration 和 status 对应的查询条件
    let SQL_STR = QUERY_ALL_PLANS_SQL

    if (status !== undefined) {
      SQL_STR += ' AND p.status = ' + status ? '已完成' : '未完成'
    }

    if (duration !== undefined) {
      SQL_STR += ' AND p.duration = ' + duration
    }

    await this.store?.querySql(SQL_STR)
      .then((resultSet: relationalStore.ResultSet) => {
        // 使用 goToNextRow 获取查询结果的每一行
        while (resultSet.goToNextRow()) {
          hilog.info(0x0000, LOG_TAG, JSON.stringify(resultSet.getRow()))
          // 获取详细字段时，需要使用类型转换

          const id: number = resultSet.getValue(resultSet.getColumnIndex('ID')) as number
          const name:string = resultSet.getValue(resultSet.getColumnIndex('NAME')) as string
          const type:string = resultSet.getValue(resultSet.getColumnIndex('TYPE')) as string
          const duration:number = resultSet.getValue(resultSet.getColumnIndex('DURATION')) as number
          const status:string = resultSet.getValue(resultSet.getColumnIndex('STATUS')) as string

          plansSet.push(new GoalItem(id, name, type, duration, status))
        }
        resultSet.close()
      })
      .catch((err: BusinessError) => {
        hilog.error(0x0000, LOG_TAG, `Query faild, error code: ${err.code}, message: ${err.message}`)
      })

    return plansSet
  }

  // 添加计划
  async addPlan(sportID: number, duration: number, status: boolean) {
    const planData: relationalStore.ValuesBucket = {
      'SPORT_ID': sportID,
      'DURATION': duration,
      'STATUS': status ? '已完成' : '未完成'
    }

    await this.store?.insert('PLANS', planData, relationalStore.ConflictResolution.ON_CONFLICT_REPLACE)
      .then((insertRowID: number) => {
        hilog.info(0x0000, LOG_TAG, `${insertRowID} row has inserted`)
      })
      .catch((err: BusinessError) => {
        hilog.error(0x0000, LOG_TAG, `Insert failed, error code: ${err.code}, message: ${err.message}`)
      })
  }

  // 编辑计划
  async updatePlan(planID: number, duration: number, status: boolean) {
    const planData: relationalStore.ValuesBucket = {
      'DURATION': duration,
      'STATUS': status ? '已完成' : '未完成'
    }
    //
    let predicates = new relationalStore.RdbPredicates('PLANS')
    predicates.equalTo('ID', planID)
    //
    // await this.store?.update(planData, predicates, relationalStore.ConflictResolution.ON_CONFLICT_REPLACE)
    //   .then((updateRowsCount: number) => {
    //     hilog.info(0x0000, LOG_TAG, `${updateRowsCount} rows has updated`)
    //   })
    //   .catch((err: BusinessError) => {
    //     hilog.error(0x0000, LOG_TAG, `Update failed, error code: ${err.code}, message: ${err.message}`)
    //   })

    // 另一种方式，使用事务对象执行，以避免数据不一致
    await this.store?.createTransaction()
      .then((transaction: relationalStore.Transaction) => {
        transaction.update(planData, predicates, relationalStore.ConflictResolution.ON_CONFLICT_REPLACE)
          .then((updateRowsCount: number) => {
            // 使用 commit 提交事务
            transaction.commit()
            hilog.info(0x0000, LOG_TAG, `${updateRowsCount} rows has updated`)
          })
          .catch((err: BusinessError) => {
            // 使用 rollback 回滚事务
            transaction.rollback()
            hilog.error(0x0000, LOG_TAG, `Update failed, error code: ${err.code}, message: ${err.message}`)
          })
      })
      .catch((err: BusinessError) => {
        hilog.error(0x0000, LOG_TAG, `Create transaction failed, error code: ${err.code}, message: ${err.message}`)
      })
  }

  // 删除计划
  async deletePlan(planID: number) {
    let predicates = new relationalStore.RdbPredicates('PLANS')
    predicates.equalTo('ID', planID)
    await this.store?.delete(predicates)
      .then((deleteRowsCount: number) => {
        hilog.info(0x0000, LOG_TAG, `${deleteRowsCount} rows has deleted`)
      })
      .catch((err: BusinessError) => {
        hilog.error(0x0000, LOG_TAG, `Delete failed, error code: ${err.code}, message: ${err.message}`)
      })
  }

  // 测试全文检索表
  async testFTSTable() {
    // 创建全文检索表
    const SQL_CREATE_TABLE = "CREATE VIRTUAL TABLE example USING fts4(name, content, tokenize=icu zh_CN)";
    this.store?.executeSql(SQL_CREATE_TABLE, (err: BusinessError) => {
      if (err) {
        console.error(`Failed to creating fts table.`);
        return;
      }
      console.info(`Succeeded in creating fts table.`);
    })

    // 测试全文检索
    this.store?.querySql("SELECT name FROM example WHERE example MATCH '测试'", (err, resultSet) => {
        if (err) {
          console.error(`Query failed.`);
          return;
        }
        while (resultSet.goToNextRow()) {
          const name = resultSet.getString(resultSet.getColumnIndex("name"));
          console.info(`name=${name}`);
        }
        resultSet.close();
      })
  }

  // 测试数据库备份与恢复
  async testBackup() {
    // 默认在 db 文件相同路径下备份，
    this.store?.backup('Backup.db', (err: BusinessError) => {
      if (err) {
        hilog.error(0x0000, LOG_TAG, `Backup Failed, error code: ${err.code}, message: ${err.message}`)
        return
      }
      hilog.info(0x0000, LOG_TAG, `Backup Successed`)
    })
  }

  async testRestore() {
    this.store?.restore('Backup.db', (err: BusinessError) => {
      if (err) {
        hilog.error(0x0000, LOG_TAG, `Restore Failed, error code: ${err.code}, message: ${err.message}`)
        return
      }
      hilog.info(0x0000, LOG_TAG, `Restore Successed`)
    })
  }

  // 删库跑路
  async dropDatabase(context: Context) {
    relationalStore.deleteRdbStore(context, STORE_CONFIG.name, (err: BusinessError) => {
      if (err) {
        hilog.error(0x0000, LOG_TAG, `Delete Store failed, error code: ${err.code}, message: ${err.message}`)
      }
      hilog.info(0x0000, LOG_TAG, `Delete Store Successed`)
    })
  }
}

export default new RDBStoreUtils()