import MetadataViews from "../../core-contracts/MetadataViews.cdc"
import FLOATEventSeries from "../FLOATEventSeries.cdc"
import FLOATEventSeriesGoals from "../FLOATEventSeriesGoals.cdc"

transaction(
  seriesId: UInt64,
  points: UInt64,
  eventsAmount: UInt64,
  requiredEventsAmount: UInt64,
  title: String?
) {
  let eventSeries: &FLOATEventSeries.EventSeries

  prepare(acct: AuthAccount) {
    // SETUP Event Series builder resource, link public and private
    if acct.borrow<&FLOATEventSeries.EventSeriesBuilder>(from: FLOATEventSeries.FLOATEventSeriesBuilderStoragePath) == nil {
      acct.save(<- FLOATEventSeries.createEventSeriesBuilder(), to: FLOATEventSeries.FLOATEventSeriesBuilderStoragePath)
      acct.link<&FLOATEventSeries.EventSeriesBuilder{FLOATEventSeries.EventSeriesBuilderPublic, MetadataViews.ResolverCollection}>
          (FLOATEventSeries.FLOATEventSeriesBuilderPublicPath, target: FLOATEventSeries.FLOATEventSeriesBuilderStoragePath)
    }

    let serieshelf = acct.borrow<&FLOATEventSeries.EventSeriesBuilder>(from: FLOATEventSeries.FLOATEventSeriesBuilderStoragePath)
      ?? panic("Could not borrow the Event Series builder.")
    
    self.eventSeries = serieshelf.borrowEventSeries(seriesId: seriesId)
      ?? panic("Could not borrow the event series private.")
  }

  pre {
    points > 0: "points should be greator then zero"
    eventsAmount >= requiredEventsAmount: "events(required) should not be greator then events"
  }

  execute {
    if requiredEventsAmount > 0 {
      let slots = self.eventSeries.getSlots()
      var totalRequiredAmount: UInt64 = 0
      for slot in slots {
        if slot.isEventRequired() {
          totalRequiredAmount = totalRequiredAmount + 1
        }
      }
      assert(requiredEventsAmount <= totalRequiredAmount, message: "Too many required amount, max = ".concat(totalRequiredAmount.toString()))
    }

    let goal = FLOATEventSeriesGoals.CollectByAmountGoal(
      points: points,
      amount: eventsAmount,
      requiredAmount: requiredEventsAmount,
      title: title
    )
    self.eventSeries.addAchievementGoal(goal: goal)

    log("A achievement goal have been added to a FLOAT EventSeries.")
  }
}
