import FLOATEventSeries from "../FLOATEventSeries.cdc"

pub fun main(accountAddr: Address): Bool {
  let acct = getAccount(accountAddr)

  if acct.getCapability<&FLOATEventSeries.EventSeriesBuilder{FLOATEventSeries.EventSeriesBuilderPublic}>
    (FLOATEventSeries.FLOATEventSeriesBuilderPublicPath).borrow() == nil {
    return false
  }

  if acct.getCapability<&FLOATEventSeries.AchievementBoard{FLOATEventSeries.AchievementBoardPublic}>
    (FLOATEventSeries.FLOATAchievementBoardPublicPath).borrow() == nil {
    return false
  }

  return true
}