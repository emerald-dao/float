import FLOATEventSeries from "../FLOATEventSeries.cdc"
import MetadataViews from "../../core-contracts/MetadataViews.cdc"

transaction(
  name: String,
  description: String,
  image: String,
  emptySlots: UInt64,
  emptySlotsRequired: UInt64,
  presetHosts: [Address],
  presetEventIds: [UInt64],
  presetRequired: [Bool]
) {
  let serieshelf: &FLOATEventSeries.EventSeriesBuilder

  prepare(acct: AuthAccount) {
    // SETUP Event Series builder resource, link public and private
    if acct.borrow<&FLOATEventSeries.EventSeriesBuilder>(from: FLOATEventSeries.FLOATEventSeriesBuilderStoragePath) == nil {
      acct.save(<- FLOATEventSeries.createEventSeriesBuilder(), to: FLOATEventSeries.FLOATEventSeriesBuilderStoragePath)
      acct.link<&FLOATEventSeries.EventSeriesBuilder{FLOATEventSeries.EventSeriesBuilderPublic, MetadataViews.ResolverCollection}>
          (FLOATEventSeries.FLOATEventSeriesBuilderPublicPath, target: FLOATEventSeries.FLOATEventSeriesBuilderStoragePath)
    }

    // SETUP Achievement Board resource, link public
    if acct.borrow<&FLOATEventSeries.AchievementBoard>(from: FLOATEventSeries.FLOATAchievementBoardStoragePath) == nil {
      acct.save(<- FLOATEventSeries.createAchievementBoard(), to: FLOATEventSeries.FLOATAchievementBoardStoragePath)
      acct.link<&FLOATEventSeries.AchievementBoard{FLOATEventSeries.AchievementBoardPublic}>
          (FLOATEventSeries.FLOATAchievementBoardPublicPath, target: FLOATEventSeries.FLOATAchievementBoardStoragePath)
    }

    self.serieshelf = acct.borrow<&FLOATEventSeries.EventSeriesBuilder>(from: FLOATEventSeries.FLOATEventSeriesBuilderStoragePath)
      ?? panic("Could not borrow the Event Series builder.")
  }

  pre {
    emptySlots >= emptySlotsRequired: "empty slots(required) should not be greator then empty slots"
    Int(emptySlots) + presetHosts.length > 0: "event slots should be greator then zero."
    presetHosts.length == presetEventIds.length: "preset slots should be same length"
    presetEventIds.length == presetRequired.length: "preset slots should be same length"
  }

  execute {
    let slots: [{FLOATEventSeries.EventSlot}] = []
    // add preset slots
    let presetLen = presetHosts.length
    var presetCnt: Int = 0
    while presetCnt < presetLen {
      let eventIdentifier = FLOATEventSeries.EventIdentifier(presetHosts[presetCnt], presetEventIds[presetCnt])
      if presetRequired[presetCnt] {
        slots.append(FLOATEventSeries.RequiredEventSlot(eventIdentifier))
      } else {
        slots.append(FLOATEventSeries.OptionalEventSlot(eventIdentifier))
      }
      presetCnt = presetCnt + 1
    }

    // add empty slots
    var emptyCnt: UInt64 = 0
    while emptyCnt < emptySlots { 
      slots.append(FLOATEventSeries.EmptyEventSlot(emptyCnt < emptySlotsRequired))
      emptyCnt = emptyCnt + 1
    }

    let goals: [{FLOATEventSeries.IAchievementGoal}] = []
    let extra: {String: AnyStruct} = {}

    self.serieshelf.createEventSeries(name: name, description: description, image: image, slots: slots, goals: goals, extra: extra)

    log("Created a FLOAT EventSeries.")
  }
}
