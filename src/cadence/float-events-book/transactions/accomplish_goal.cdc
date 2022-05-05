import FLOATEventsBook from "../FLOATEventsBook.cdc"

transaction(
  host: Address,
  bookId: UInt64,
  goalIdx: UInt64
) {
  let achievementRecord: &{FLOATEventsBook.AchievementPublic, FLOATEventsBook.AchievementWritable}

  prepare(acct: AuthAccount) {
    // SETUP Achievement Board resource, link public
    if acct.borrow<&FLOATEventsBook.AchievementBoard>(from: FLOATEventsBook.FLOATAchievementBoardStoragePath) == nil {
      acct.save(<- FLOATEventsBook.createAchievementBoard(), to: FLOATEventsBook.FLOATAchievementBoardStoragePath)
      acct.link<&FLOATEventsBook.AchievementBoard{FLOATEventsBook.AchievementBoardPublic}>
          (FLOATEventsBook.FLOATAchievementBoardPublicPath, target: FLOATEventsBook.FLOATAchievementBoardStoragePath)
    }

    let achievementBoard = acct.borrow<&FLOATEventsBook.AchievementBoard>(from: FLOATEventsBook.FLOATAchievementBoardStoragePath)
      ?? panic("Could not borrow the AchievementBoard from the signer.")
    
    if let record = achievementBoard.borrowAchievementRecordWritable(host: host, bookId: bookId) {
      self.achievementRecord = record
    } else {
      achievementBoard.createAchievementRecord(host: host, bookId: bookId)
      self.achievementRecord = achievementBoard.borrowAchievementRecordWritable(host: host, bookId: bookId)
        ?? panic("Could not borrow the Achievement record")
    }
  }

  execute {
    self.achievementRecord.accomplishGoal(goalIdx: Int(goalIdx))

    log("Goal idx[".concat(goalIdx.toString()).concat("] was accomplished"))
  }
}
 