import MetadataViews from "../../core-contracts/MetadataViews.cdc"
import FungibleToken from "../../core-contracts/FungibleToken.cdc"
import FLOATEventsBook from "../FLOATEventSeries.cdc"

transaction(
  bookId: UInt64,
  strategyIndex: Int,
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
    
    // events book
    self.eventsBook = bookshelf.borrowEventsBookPrivate(bookId: bookId)
      ?? panic("Could not borrow the events book private.")
  }

  execute {
    let treasury = self.eventsBook.borrowTreasuryPrivate()
    treasury.nextStrategyStage(idx: strategyIndex)

    log("Strategy go to next step.")
  }
}
