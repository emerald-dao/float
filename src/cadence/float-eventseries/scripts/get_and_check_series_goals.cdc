import FLOATEventSeries from "../FLOATEventSeries.cdc"
import FLOATEventSeriesGoals from "../FLOATEventSeriesGoals.cdc"

pub fun main(
  accountAddr: Address,
  host: Address,
  seriesId: UInt64
): [FLOATEventSeriesGoals.GoalStatusDisplay] {
  let eventSeriesRef = FLOATEventSeries.EventSeriesIdentifier(host, seriesId).getEventSeriesPublic()

  var verifyFunc: ((Int): FLOATEventSeriesGoals.GoalStatus)? = nil

  if let achievementBoard = getAccount(accountAddr)
    .getCapability(FLOATEventSeries.FLOATAchievementBoardPublicPath)
    .borrow<&FLOATEventSeries.AchievementBoard{FLOATEventSeries.AchievementBoardPublic}>()
  {
    // build goal status by different ways
    if let record = achievementBoard.borrowAchievementRecordRef(host: host, seriesId: seriesId) {
      // when record is created
      let finishedGoals = record.getFinishedGoals()

      verifyFunc = fun (goalIdx: Int): FLOATEventSeriesGoals.GoalStatus {
        var status = FLOATEventSeriesGoals.GoalStatus.todo
        if finishedGoals.contains(goalIdx) {
          status = FLOATEventSeriesGoals.GoalStatus.accomplished
        } else if record.isGoalReady(goalIdx: goalIdx) {
          status = FLOATEventSeriesGoals.GoalStatus.ready
        }
        return status
      }
    }
  }

  // use more general method
  if verifyFunc == nil {
    verifyFunc = fun (goalIdx: Int): FLOATEventSeriesGoals.GoalStatus {
      let isReady = eventSeriesRef.checkGoalsReached(user: accountAddr, idxs: [goalIdx])
      return isReady[0] ? FLOATEventSeriesGoals.GoalStatus.ready : FLOATEventSeriesGoals.GoalStatus.todo
    }
  }

  // the final data
  let ret: [FLOATEventSeriesGoals.GoalStatusDisplay] = []
  let goals = eventSeriesRef.getGoals()

  for i, goal in goals {
    ret.append(FLOATEventSeriesGoals.GoalStatusDisplay(
      status: verifyFunc!(i),
      identifer: goal.getType().identifier,
      title: goal.title,
      points: goal.getPoints(),
      detail: goal.getGoalDetail()
    ))
  }
  return ret
}