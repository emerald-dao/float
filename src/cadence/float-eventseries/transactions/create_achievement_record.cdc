import FLOATEventSeries from "../FLOATEventSeries.cdc"

transaction(
  host: Address,
  bookId: UInt64
) {
  let achievementBoard: &FLOATEventSeries.AchievementBoard

  prepare(acct: AuthAccount) {
    // SETUP Achievement Board resource, link public
    if acct.borrow<&FLOATEventSeries.AchievementBoard>(from: FLOATEventSeries.FLOATAchievementBoardStoragePath) == nil {
      acct.save(<- FLOATEventSeries.createAchievementBoard(), to: FLOATEventSeries.FLOATAchievementBoardStoragePath)
      acct.link<&FLOATEventSeries.AchievementBoard{FLOATEventSeries.AchievementBoardPublic}>
          (FLOATEventSeries.FLOATAchievementBoardPublicPath, target: FLOATEventSeries.FLOATAchievementBoardStoragePath)
    }

    self.achievementBoard = acct.borrow<&FLOATEventSeries.AchievementBoard>(from: FLOATEventSeries.FLOATAchievementBoardStoragePath)
      ?? panic("Could not borrow the AchievementBoard from the signer.")
  }

  execute {
    let identifier = self.achievementBoard.createAchievementRecord(host: host, bookId: bookId)
    log("Created a new achievement record[".concat(identifier.toString()).concat("] for signer."))
  }
}