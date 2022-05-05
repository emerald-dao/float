import MetadataViews from "../../core-contracts/MetadataViews.cdc"
import FLOATEventsBook from "../FLOATEventsBook.cdc"
import FLOATStrategies from "../FLOATStrategies.cdc"

transaction(
  bookId: UInt64,
  points: UInt64,
  eventHosts: [Address],
  eventIds: [UInt64],
) {
  let eventsBook: &FLOATEventsBook.EventsBook{FLOATEventsBook.EventsBookPublic, FLOATEventsBook.EventsBookPrivate}

  prepare(acct: AuthAccount) {
    // SETUP Bookshelf resource, link public and private
    if acct.borrow<&FLOATEventsBook.EventsBookshelf>(from: FLOATEventsBook.FLOATEventsBookshelfStoragePath) == nil {
      acct.save(<- FLOATEventsBook.createEventsBookshelf(), to: FLOATEventsBook.FLOATEventsBookshelfStoragePath)
      acct.link<&FLOATEventsBook.EventsBookshelf{FLOATEventsBook.EventsBookshelfPublic, MetadataViews.ResolverCollection}>
          (FLOATEventsBook.FLOATEventsBookshelfPublicPath, target: FLOATEventsBook.FLOATEventsBookshelfStoragePath)
      acct.link<&FLOATEventsBook.EventsBookshelf{FLOATEventsBook.EventsBookshelfPrivate}>
          (FLOATEventsBook.FLOATEventsBookshelfPrivatePath, target: FLOATEventsBook.FLOATEventsBookshelfStoragePath)
    }

    let bookshelf = acct.borrow<&FLOATEventsBook.EventsBookshelf>(from: FLOATEventsBook.FLOATEventsBookshelfStoragePath)
      ?? panic("Could not borrow the Bookshelf.")
    
    self.eventsBook = bookshelf.borrowEventsBookPrivate(bookId: bookId)
      ?? panic("Could not borrow the events book private.")
  }

  pre {
    points > 0: "points should be greator then zero"
    eventHosts.length == eventIds.length: "Array of event parameters should be with same length"
  }

  execute {
    let floats: [FLOATEventsBook.EventIdentifier] = []

    let presetLen = eventHosts.length
    var i = 0
    while i < presetLen {
      floats.append(FLOATEventsBook.EventIdentifier(eventHosts[i], eventIds[i]))
      i = i + 1
    }

    let goal = FLOATStrategies.CollectSpecificFLOATsGoal(
      points: points,
      floats: floats
    )
    self.eventsBook.addAchievementGoal(goal: goal)

    log("A achievement goal have been added to a FLOAT EventsBook.")
  }
}
