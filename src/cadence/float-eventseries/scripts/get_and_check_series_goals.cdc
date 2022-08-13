import FLOAT from "../../float/FLOAT.cdc"
import FLOATEventSeries from "../FLOATEventSeries.cdc"
import FLOATEventSeriesGoals from "../FLOATEventSeriesGoals.cdc"

pub fun main(
  accountAddr: Address,
  host: Address,
  seriesId: UInt64
): Status {
  // series
  let eventSeriesRef = FLOATEventSeries.EventSeriesIdentifier(host, seriesId).getEventSeriesPublic()
  // floats
  let floatsColRef = getAccount(accountAddr)
    .getCapability(FLOAT.FLOATCollectionPublicPath)
    .borrow<&FLOAT.Collection{FLOAT.CollectionPublic}>()

  var verifyFunc: ((Int): FLOATEventSeriesGoals.GoalStatus)? = nil
  var totalScore: UInt64 = 0
  var consumableScore: UInt64 = 0

  if let achievementBoard = getAccount(accountAddr)
    .getCapability(FLOATEventSeries.FLOATAchievementBoardPublicPath)
    .borrow<&FLOATEventSeries.AchievementBoard{FLOATEventSeries.AchievementBoardPublic}>()
  {
    // build goal status by different ways
    if let record = achievementBoard.borrowAchievementRecordRef(host: host, seriesId: seriesId) {
      // when record is created
      let finishedGoals = record.getFinishedGoals()
      totalScore = record.getTotalScore()
      consumableScore = record.getConsumableScore()

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

  // goals final data
  let goalsRet: [FLOATEventSeriesGoals.GoalStatusDisplay] = []
  let goals = eventSeriesRef.getGoals()

  for i, goal in goals {
    goalsRet.append(FLOATEventSeriesGoals.GoalStatusDisplay(
      status: verifyFunc!(i),
      identifer: goal.getType().identifier,
      title: goal.title,
      points: goal.getPoints(),
      detail: goal.getGoalDetail()
    ))
  }

  // get floats data
  let ownedIds: [FLOATEventSeries.EventIdentifier] = []
  if floatsColRef != nil {
  let slots = eventSeriesRef.getSlots()
    for slot in slots {
      if let eventIdentifier = slot.getIdentifier() {
        let ids = floatsColRef!.ownedIdsFromEvent(eventId: eventIdentifier.eventId)
        if ids.length > 0 {
          ownedIds.append(eventIdentifier)
        }
      }
    }
  }

  return Status(goalsRet, ownedIds, totalScore, consumableScore)
}

pub struct Status {
  pub let goals: [FLOATEventSeriesGoals.GoalStatusDisplay]
  pub let owned: [FLOATEventSeries.EventIdentifier]
  pub let totalScore: UInt64
  pub let consumableScore: UInt64

  init(
    _ goals: [FLOATEventSeriesGoals.GoalStatusDisplay],
    _ ids: [FLOATEventSeries.EventIdentifier],
    _ totalScore: UInt64,
    _ consumableScore: UInt64,
  ) {
    self.goals = goals
    self.owned = ids
    self.totalScore = totalScore
    self.consumableScore = consumableScore
  }
}