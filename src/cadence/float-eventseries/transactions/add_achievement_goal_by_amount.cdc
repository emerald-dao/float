import MetadataViews from "../../core-contracts/MetadataViews.cdc"
import FLOATEventsBook from "../FLOATEventSeries.cdc"
import FLOATStrategies from "../FLOATStrategies.cdc"

transaction(
  bookId: UInt64,
  points: UInt64,
  eventsAmount: UInt64,
  requiredEventsAmount: UInt64
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
    eventsAmount >= requiredEventsAmount: "events(required) should not be greator then events"
  }

  execute {
    let goal = FLOATStrategies.CollectByAmountGoal(
      points: points,
      amount: eventsAmount,
      requiredAmount: requiredEventsAmount
    )
    self.eventsBook.addAchievementGoal(goal: goal)

    log("A achievement goal have been added to a FLOAT EventsBook.")
  }
}
