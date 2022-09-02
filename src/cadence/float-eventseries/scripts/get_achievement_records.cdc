import FLOATEventSeries from "../FLOATEventSeries.cdc"

pub struct AchievementRecord {
  pub let host: Address
  pub let seriesId: UInt64
  pub let score: UInt64
  pub let consumableScore: UInt64

  init(
    _ host: Address,
    _ seriesId: UInt64,
    _ score: UInt64,
    _ consumable: UInt64
  ) {
    self.host = host
    self.seriesId = seriesId
    self.score = score
    self.consumableScore = consumable
  }
}

pub fun main(
  accountAddr: Address,
  host: Address,
  seriesIds: [UInt64]
): [AchievementRecord] {
  let acct = getAccount(accountAddr)

  let achievementBoard = acct
    .getCapability<&FLOATEventSeries.AchievementBoard{FLOATEventSeries.AchievementBoardPublic}>
      (FLOATEventSeries.FLOATAchievementBoardPublicPath)
    .borrow()
  if achievementBoard == nil {
    return []
  }

  let ret: [AchievementRecord] = []
  for seriesId in seriesIds {
    let record = achievementBoard!.borrowAchievementRecordRef(host: host, seriesId: seriesId)
    if record == nil {
      continue
    }
    ret.append(AchievementRecord(host, seriesId, record!.score, record!.consumableScore))
  }

  return ret
}