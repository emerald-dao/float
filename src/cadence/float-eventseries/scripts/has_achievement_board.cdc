import FLOATEventSeries from "../FLOATEventSeries.cdc"

pub fun main(accountAddr: Address): Bool {
  let acct = getAccount(accountAddr)

  if acct.getCapability<&FLOATEventSeries.AchievementBoard{FLOATEventSeries.AchievementBoardPublic}>
    (FLOATEventSeries.FLOATAchievementBoardPublicPath).borrow() == nil {
    return false
  }

  return true
}