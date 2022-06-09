import FLOATEventsBook from "../FLOATEventSeries.cdc"
import MetadataViews from "../../core-contracts/MetadataViews.cdc"

transaction(
  host: Address,
  bookId: UInt64,
  strategyIndex: UInt64,
) {
  let achievementRecord: &{FLOATEventsBook.AchievementPublic, FLOATEventsBook.AchievementWritable}
  let eventsBook: &{FLOATEventsBook.EventsBookPublic}

  prepare(acct: AuthAccount) {
    // SETUP Achievement Board resource, link public
    if acct.borrow<&FLOATEventsBook.AchievementBoard>(from: FLOATEventsBook.FLOATAchievementBoardStoragePath) == nil {
      acct.save(<- FLOATEventsBook.createAchievementBoard(), to: FLOATEventsBook.FLOATAchievementBoardStoragePath)
      acct.link<&FLOATEventsBook.AchievementBoard{FLOATEventsBook.AchievementBoardPublic}>
          (FLOATEventsBook.FLOATAchievementBoardPublicPath, target: FLOATEventsBook.FLOATAchievementBoardStoragePath)
    }

    // get achievement record from signer
    let achievementBoard = acct.borrow<&FLOATEventsBook.AchievementBoard>(from: FLOATEventsBook.FLOATAchievementBoardStoragePath)
      ?? panic("Could not borrow the AchievementBoard from the signer.")
    
    if let record = achievementBoard.borrowAchievementRecordWritable(host: host, bookId: bookId) {
      self.achievementRecord = record
    } else {
      achievementBoard.createAchievementRecord(host: host, bookId: bookId)
      self.achievementRecord = achievementBoard.borrowAchievementRecordWritable(host: host, bookId: bookId)
        ?? panic("Could not borrow the Achievement record")
    }

    // get EventsBook from host
    let bookshelf = getAccount(host)
      .getCapability(FLOATEventsBook.FLOATEventsBookshelfPublicPath)
      .borrow<&FLOATEventsBook.EventsBookshelf{FLOATEventsBook.EventsBookshelfPublic}>()
      ?? panic("Could not borrow the public EventsBookshelfPublic.")
    
    self.eventsBook = bookshelf.borrowEventsBook(bookId: bookId)
      ?? panic("Failed to get events book reference.")
  }

  execute {
    let treasury = self.eventsBook.borrowTreasury()
    treasury.claim(strategyIndex: Int(strategyIndex), user: self.achievementRecord)

    log("Claimed your rewards from treasury.")
  }
}
