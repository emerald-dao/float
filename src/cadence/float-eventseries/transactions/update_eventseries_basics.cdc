import FLOATEventsBook from "../FLOATEventSeries.cdc"
import MetadataViews from "../../core-contracts/MetadataViews.cdc"

transaction(
  bookId: UInt64,
  name: String,
  description: String,
  image: String
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

  execute {

    self.eventsBook.updateBasics(name: name, description: description, image: image)

    log("Update the basics of a FLOAT EventsBook.")
  }
}
