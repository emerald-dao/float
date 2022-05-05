import FLOATEventsBook from "../FLOATEventsBook.cdc"

transaction(
  host: Address,
  bookId: UInt64
) {
  let achievementBoard: &FLOATEventsBook.AchievementBoard

  prepare(acct: AuthAccount) {
    // SETUP Achievement Board resource, link public
    if acct.borrow<&FLOATEventsBook.AchievementBoard>(from: FLOATEventsBook.FLOATAchievementBoardStoragePath) == nil {
      acct.save(<- FLOATEventsBook.createAchievementBoard(), to: FLOATEventsBook.FLOATAchievementBoardStoragePath)
      acct.link<&FLOATEventsBook.AchievementBoard{FLOATEventsBook.AchievementBoardPublic}>
          (FLOATEventsBook.FLOATAchievementBoardPublicPath, target: FLOATEventsBook.FLOATAchievementBoardStoragePath)
    }

    self.achievementBoard = acct.borrow<&FLOATEventsBook.AchievementBoard>(from: FLOATEventsBook.FLOATAchievementBoardStoragePath)
      ?? panic("Could not borrow the AchievementBoard from the signer.")
  }

  execute {
    let identifier = self.achievementBoard.createAchievementRecord(host: host, bookId: bookId)
    log("Created a new achievement record[".concat(identifier.toString()).concat("] for signer."))
  }
}