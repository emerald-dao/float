import FLOATEventsBook from "../FLOATEventSeries.cdc"
import MetadataViews from "../../core-contracts/MetadataViews.cdc"

transaction(
  bookId: UInt64,
  slotIndexes: [UInt64],
  slotHosts: [Address],
  slotEventIds: [UInt64],
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
    slotIndexes.length == slotHosts.length: "slots should be same length"
    slotHosts.length == slotEventIds.length: "slots should be same length"
  }

  execute {
    let presetLen = slotIndexes.length
    var i = 0
    while i < presetLen {
      let eventIdentifier = FLOATEventsBook.EventIdentifier(slotHosts[i], slotEventIds[i])
      self.eventsBook.updateSlotData(idx: Int(slotIndexes[i]), identifier: eventIdentifier)
      i = i + 1
    }
    log("Update the slot identifiers of a FLOAT EventsBook.")
  }
}
