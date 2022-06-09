import FLOATEventsBook from "../FLOATEventSeries.cdc"
import MetadataViews from "../../core-contracts/MetadataViews.cdc"

transaction {

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
  }

  execute {
    log("Finished setting up the account for FLOAT EventsBook.")
  }
}
