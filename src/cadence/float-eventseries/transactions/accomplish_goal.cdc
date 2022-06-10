import FLOATEventSeries from "../FLOATEventSeries.cdc"

transaction(
  host: Address,
  seriesId: UInt64,
  goalIdx: UInt64
) {
  let achievementRecord: &{FLOATEventSeries.AchievementPublic, FLOATEventSeries.AchievementWritable}

  prepare(acct: AuthAccount) {
    // SETUP Achievement Board resource, link public
    if acct.borrow<&FLOATEventSeries.AchievementBoard>(from: FLOATEventSeries.FLOATAchievementBoardStoragePath) == nil {
      acct.save(<- FLOATEventSeries.createAchievementBoard(), to: FLOATEventSeries.FLOATAchievementBoardStoragePath)
      acct.link<&FLOATEventSeries.AchievementBoard{FLOATEventSeries.AchievementBoardPublic}>
          (FLOATEventSeries.FLOATAchievementBoardPublicPath, target: FLOATEventSeries.FLOATAchievementBoardStoragePath)
    }

    let achievementBoard = acct.borrow<&FLOATEventSeries.AchievementBoard>(from: FLOATEventSeries.FLOATAchievementBoardStoragePath)
      ?? panic("Could not borrow the AchievementBoard from the signer.")
    
    if let record = achievementBoard.borrowAchievementRecordWritable(host: host, seriesId: seriesId) {
      self.achievementRecord = record
    } else {
      achievementBoard.createAchievementRecord(host: host, seriesId: seriesId)
      self.achievementRecord = achievementBoard.borrowAchievementRecordWritable(host: host, seriesId: seriesId)
        ?? panic("Could not borrow the Achievement record")
    }
  }

  execute {
    self.achievementRecord.accomplishGoal(goalIdx: Int(goalIdx))

    log("Goal idx[".concat(goalIdx.toString()).concat("] was accomplished"))
  }
}
 