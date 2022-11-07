import FLOATEventSeries from "../FLOATEventSeries.cdc"
import MetadataViews from "../../core-contracts/MetadataViews.cdc"

transaction(
  host: Address,
  seriesId: UInt64,
) {
  let achievementRecord: &FLOATEventSeries.Achievement
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
    
    if let record = achievementBoard.borrowAchievementRecordWritable(host: host, seriesId: seriesId) {
      self.achievementRecord = record
    } else {
      achievementBoard.createAchievementRecord(host: host, seriesId: seriesId)
      self.achievementRecord = achievementBoard.borrowAchievementRecordWritable(host: host, seriesId: seriesId)
        ?? panic("Could not borrow the Achievement record")
    }

    // get EventSeries from host
    let serieshelf = getAccount(host)
      .getCapability(FLOATEventSeries.FLOATEventSeriesBuilderPublicPath)
      .borrow<&FLOATEventSeries.EventSeriesBuilder{FLOATEventSeries.EventSeriesBuilderPublic}>()
      ?? panic("Could not borrow the public EventSeriesBuilderPublic.")
    
    self.eventSeries = serieshelf.borrowEventSeriesPublic(seriesId: seriesId)
      ?? panic("Failed to get event series reference.")
  }

  execute {
    let treasury = self.eventSeries.borrowTreasuryPublic()
    treasury.refreshUserStatus(user: self.achievementRecord)

    log("Refresh user status of the treasury.")
  }
}

