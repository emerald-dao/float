import FLOATEventsBook from "../FLOATEventSeries.cdc"

pub struct AchievementRecord {
  pub let host: Address
  pub let bookId: UInt64
  pub let score: UInt64
  pub let consumableScore: UInt64

  init(
    _ host: Address,
    _ bookId: UInt64,
    _ score: UInt64,
    _ consumable: UInt64
  ) {
    self.host = host
    self.bookId = bookId
    self.score = score
    self.consumableScore = consumable
  }
}

pub fun main(
  accountAddr: Address,
  host: Address,
  bookIds: [UInt64]
): [AchievementRecord] {
  let acct = getAccount(accountAddr)

  let achievementBoard = acct
    .getCapability<&FLOATEventsBook.AchievementBoard{FLOATEventsBook.AchievementBoardPublic}>
      (FLOATEventsBook.FLOATAchievementBoardPublicPath)
    .borrow()
  if achievementBoard == nil {
    return []
  }

  let ret: [AchievementRecord] = []
  for bookId in bookIds {
    let record = achievementBoard!.borrowAchievementRecordRef(host: host, bookId: bookId)
    if record == nil {
      continue
    }
    ret.append(AchievementRecord(host, bookId, record!.getTotalScore(), record!.getConsumableScore()))
  }

  return ret
}