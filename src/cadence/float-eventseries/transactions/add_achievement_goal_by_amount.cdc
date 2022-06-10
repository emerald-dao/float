import MetadataViews from "../../core-contracts/MetadataViews.cdc"
import FLOATEventSeries from "../FLOATEventSeries.cdc"
import FLOATStrategies from "../FLOATStrategies.cdc"

transaction(
  seriesId: UInt64,
  points: UInt64,
  eventsAmount: UInt64,
  requiredEventsAmount: UInt64
) {
  let eventSeries: &FLOATEventSeries.EventSeries{FLOATEventSeries.EventSeriesPublic, FLOATEventSeries.EventSeriesPrivate}

  prepare(acct: AuthAccount) {
    // SETUP Event Series builder resource, link public and private
    if acct.borrow<&FLOATEventSeries.EventSeriesBuilder>(from: FLOATEventSeries.FLOATEventSeriesBuilderStoragePath) == nil {
      acct.save(<- FLOATEventSeries.createEventSeriesBuilder(), to: FLOATEventSeries.FLOATEventSeriesBuilderStoragePath)
      acct.link<&FLOATEventSeries.EventSeriesBuilder{FLOATEventSeries.EventSeriesBuilderPublic, MetadataViews.ResolverCollection}>
          (FLOATEventSeries.FLOATEventSeriesBuilderPublicPath, target: FLOATEventSeries.FLOATEventSeriesBuilderStoragePath)
      acct.link<&FLOATEventSeries.EventSeriesBuilder{FLOATEventSeries.EventSeriesBuilderPrivate}>
          (FLOATEventSeries.FLOATEventSeriesBuilderPrivatePath, target: FLOATEventSeries.FLOATEventSeriesBuilderStoragePath)
    }

    let serieshelf = acct.borrow<&FLOATEventSeries.EventSeriesBuilder>(from: FLOATEventSeries.FLOATEventSeriesBuilderStoragePath)
      ?? panic("Could not borrow the Event Series builder.")
    
    self.eventSeries = serieshelf.borrowEventSeriesPrivate(seriesId: seriesId)
      ?? panic("Could not borrow the event series private.")
  }

  pre {
    points > 0: "points should be greator then zero"
    eventsAmount >= requiredEventsAmount: "events(required) should not be greator then events"
  }

  execute {
    let goal = FLOATStrategies.CollectByAmountGoal(
      points: points,
      amount: eventsAmount,
      requiredAmount: requiredEventsAmount
    )
    self.eventSeries.addAchievementGoal(goal: goal)

    log("A achievement goal have been added to a FLOAT EventSeries.")
  }
}
