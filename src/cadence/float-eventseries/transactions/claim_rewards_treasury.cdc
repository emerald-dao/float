import FLOATEventSeries from "../FLOATEventSeries.cdc"
import MetadataViews from "../../core-contracts/MetadataViews.cdc"

transaction(
  host: Address,
  bookId: UInt64,
  strategyIndex: UInt64,
) {
  let achievementRecord: &{FLOATEventSeries.AchievementPublic, FLOATEventSeries.AchievementWritable}
  let eventSeries: &{FLOATEventSeries.EventSeriesPublic}

  prepare(acct: AuthAccount) {
    // SETUP Achievement Board resource, link public
    if acct.borrow<&FLOATEventSeries.AchievementBoard>(from: FLOATEventSeries.FLOATAchievementBoardStoragePath) == nil {
      acct.save(<- FLOATEventSeries.createAchievementBoard(), to: FLOATEventSeries.FLOATAchievementBoardStoragePath)
      acct.link<&FLOATEventSeries.AchievementBoard{FLOATEventSeries.AchievementBoardPublic}>
          (FLOATEventSeries.FLOATAchievementBoardPublicPath, target: FLOATEventSeries.FLOATAchievementBoardStoragePath)
    }

    // get achievement record from signer
    let achievementBoard = acct.borrow<&FLOATEventSeries.AchievementBoard>(from: FLOATEventSeries.FLOATAchievementBoardStoragePath)
      ?? panic("Could not borrow the AchievementBoard from the signer.")
    
    if let record = achievementBoard.borrowAchievementRecordWritable(host: host, bookId: bookId) {
      self.achievementRecord = record
    } else {
      achievementBoard.createAchievementRecord(host: host, bookId: bookId)
      self.achievementRecord = achievementBoard.borrowAchievementRecordWritable(host: host, bookId: bookId)
        ?? panic("Could not borrow the Achievement record")
    }

    // get EventSeries from host
    let bookshelf = getAccount(host)
      .getCapability(FLOATEventSeries.FLOATEventSeriesBuilderPublicPath)
      .borrow<&FLOATEventSeries.EventSeriesBuilder{FLOATEventSeries.EventSeriesBuilderPublic}>()
      ?? panic("Could not borrow the public EventSeriesBuilderPublic.")
    
    self.eventSeries = bookshelf.borrowEventSeries(bookId: bookId)
      ?? panic("Failed to get event series reference.")
  }

  execute {
    let treasury = self.eventSeries.borrowTreasury()
    treasury.claim(strategyIndex: Int(strategyIndex), user: self.achievementRecord)

    log("Claimed your rewards from treasury.")
  }
}
