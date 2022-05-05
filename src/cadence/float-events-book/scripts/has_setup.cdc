import FLOATEventsBook from "../FLOATEventsBook.cdc"

pub fun main(accountAddr: Address): Bool {
  let acct = getAccount(accountAddr)

  if acct.getCapability<&FLOATEventsBook.EventsBookshelf{FLOATEventsBook.EventsBookshelfPublic}>
    (FLOATEventsBook.FLOATEventsBookshelfPublicPath).borrow() == nil {
    return false
  }

  if acct.getCapability<&FLOATEventsBook.AchievementBoard{FLOATEventsBook.AchievementBoardPublic}>
    (FLOATEventsBook.FLOATAchievementBoardPublicPath).borrow() == nil {
    return false
  }

  return true
}