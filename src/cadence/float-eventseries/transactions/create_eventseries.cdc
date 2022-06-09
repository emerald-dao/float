import FLOATEventsBook from "../FLOATEventSeries.cdc"
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
  let bookshelf: &FLOATEventsBook.EventsBookshelf

  prepare(acct: AuthAccount) {
    // SETUP Bookshelf resource, link public and private
    if acct.borrow<&FLOATEventsBook.EventsBookshelf>(from: FLOATEventsBook.FLOATEventsBookshelfStoragePath) == nil {
      acct.save(<- FLOATEventsBook.createEventsBookshelf(), to: FLOATEventsBook.FLOATEventsBookshelfStoragePath)
      acct.link<&FLOATEventsBook.EventsBookshelf{FLOATEventsBook.EventsBookshelfPublic, MetadataViews.ResolverCollection}>
          (FLOATEventsBook.FLOATEventsBookshelfPublicPath, target: FLOATEventsBook.FLOATEventsBookshelfStoragePath)
      acct.link<&FLOATEventsBook.EventsBookshelf{FLOATEventsBook.EventsBookshelfPrivate}>
          (FLOATEventsBook.FLOATEventsBookshelfPrivatePath, target: FLOATEventsBook.FLOATEventsBookshelfStoragePath)
    }

    // SETUP Achievement Board resource, link public
    if acct.borrow<&FLOATEventsBook.AchievementBoard>(from: FLOATEventsBook.FLOATAchievementBoardStoragePath) == nil {
      acct.save(<- FLOATEventsBook.createAchievementBoard(), to: FLOATEventsBook.FLOATAchievementBoardStoragePath)
      acct.link<&FLOATEventsBook.AchievementBoard{FLOATEventsBook.AchievementBoardPublic}>
          (FLOATEventsBook.FLOATAchievementBoardPublicPath, target: FLOATEventsBook.FLOATAchievementBoardStoragePath)
    }

    self.bookshelf = acct.borrow<&FLOATEventsBook.EventsBookshelf>(from: FLOATEventsBook.FLOATEventsBookshelfStoragePath)
      ?? panic("Could not borrow the Bookshelf.")
  }

  pre {
    emptySlots >= emptySlotsRequired: "empty slots(required) should not be greator then empty slots"
    Int(emptySlots) + presetHosts.length > 0: "event slots should be greator then zero."
    presetHosts.length == presetEventIds.length: "preset slots should be same length"
    presetEventIds.length == presetRequired.length: "preset slots should be same length"
  }

  execute {
    let slots: [{FLOATEventsBook.EventSlot}] = []
    // add preset slots
    let presetLen = presetHosts.length
    var presetCnt: Int = 0
    while presetCnt < presetLen {
      let eventIdentifier = FLOATEventsBook.EventIdentifier(presetHosts[presetCnt], presetEventIds[presetCnt])
      if presetRequired[presetCnt] {
        slots.append(FLOATEventsBook.RequiredEventSlot(eventIdentifier))
      } else {
        slots.append(FLOATEventsBook.OptionalEventSlot(eventIdentifier))
      }
      presetCnt = presetCnt + 1
    }

    // add empty slots
    var emptyCnt: UInt64 = 0
    while emptyCnt < emptySlots { 
      slots.append(FLOATEventsBook.EmptyEventSlot(emptyCnt < emptySlotsRequired))
      emptyCnt = emptyCnt + 1
    }

    let goals: [{FLOATEventsBook.IAchievementGoal}] = []
    let extra: {String: AnyStruct} = {}

    self.bookshelf.createEventsBook(name: name, description: description, image: image, slots: slots, goals: goals, extra: extra)

    log("Created a FLOAT EventsBook.")
  }
}
