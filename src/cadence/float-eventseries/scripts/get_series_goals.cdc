import FLOATEventSeries from "../FLOATEventSeries.cdc"
import FLOATEventSeriesGoals from "../FLOATEventSeriesGoals.cdc"

pub fun main(
  host: Address,
  seriesId: UInt64
): [FLOATEventSeriesGoals.GoalStatusDisplay] {
  let eventSeriesRef = FLOATEventSeries.EventSeriesIdentifier(host, seriesId).getEventSeriesPublic()

  // the final data
  let ret: [FLOATEventSeriesGoals.GoalStatusDisplay] = []
  let goals = eventSeriesRef.getGoals()

  for i, goal in goals {
    ret.append(FLOATEventSeriesGoals.GoalStatusDisplay(
      status: FLOATEventSeriesGoals.GoalStatus.todo,
      identifer: goal.getType().identifier,
      title: goal.title,
      points: goal.getPoints(),
      detail: goal.getGoalDetail()
    ))
  }
  return ret
}