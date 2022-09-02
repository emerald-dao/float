import MetadataViews from "../../core-contracts/MetadataViews.cdc"
import FLOATEventSeries from "../FLOATEventSeries.cdc"
import FLOATEventSeriesGoals from "../FLOATEventSeriesGoals.cdc"

transaction(
  seriesId: UInt64,
  points: UInt64,
  eventHosts: [Address],
  eventIds: [UInt64],
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
    eventHosts.length == eventIds.length: "Array of event parameters should be with same length"
  }

  execute {
    let floats: [FLOATEventSeries.EventIdentifier] = []

    let presetLen = eventHosts.length
    var i = 0
    while i < presetLen {
      let goal = FLOATEventSeries.EventIdentifier(eventHosts[i], eventIds[i])
      goal.getEventPublic() // ensure float exits
      floats.append(goal)
      i = i + 1
    }

    let goal = FLOATEventSeriesGoals.CollectSpecificFLOATsGoal(
      points: points,
      floats: floats,
      title: title
    )
    self.eventSeries.addAchievementGoal(goal: goal)

    log("A achievement goal have been added to a FLOAT EventSeries.")
  }
}
