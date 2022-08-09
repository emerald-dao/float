import NonFungibleToken from "../../core-contracts/NonFungibleToken.cdc"
import FungibleToken from "../../core-contracts/FungibleToken.cdc"
import FLOATEventSeries from "../FLOATEventSeries.cdc"
import FLOATEventSeriesViews from "../FLOATEventSeriesViews.cdc"

pub fun main(
  host: Address,
  id: UInt64,
  includingAvailables: Bool,
  user: Address?
): Result {

  let builderRef = getAccount(host)
    .getCapability(FLOATEventSeries.FLOATEventSeriesBuilderPublicPath)
    .borrow<&FLOATEventSeries.EventSeriesBuilder{FLOATEventSeries.EventSeriesBuilderPublic}>()
    ?? panic("Missing FLOAT EventSeries Builder.")
  let eventSeries = builderRef!.borrowEventSeries(seriesId: id)
    ?? panic("Missing FLOAT EventSeries Builder.")
  let treasury = eventSeries.borrowTreasury()

  var userRecord: &{FLOATEventSeries.AchievementPublic}? = nil
  var totalScore: UInt64? = nil
  var consumableScore: UInt64? = nil
  if let currentUser = user {
    let achievementBoardRef = getAccount(currentUser)
      .getCapability<&FLOATEventSeries.AchievementBoard{FLOATEventSeries.AchievementBoardPublic}>
        (FLOATEventSeries.FLOATAchievementBoardPublicPath)
      .borrow()
    if let record = achievementBoardRef?.borrowAchievementRecordRef(host: host, seriesId: id) {
      userRecord = record
      if record != nil {
        totalScore = record!.getTotalScore()
        consumableScore = record!.getConsumableScore()
      }
    }
  }

  let strategies = treasury.getStrategies(states: [
      FLOATEventSeries.StrategyState.preparing,
      FLOATEventSeries.StrategyState.opening,
      FLOATEventSeries.StrategyState.claimable
  ], userRecord)

  if !includingAvailables {
    return Result(strategies, nil, totalScore, consumableScore)
  }

  // calc frozen data
  var frozenAmounts: {Type: UFix64} = {}
  var frozenShares: {Type: UInt64} = {}
  for strategy in strategies {
    let tokenType = strategy.detail.status.delivery.deliveryTokenType

    let restAmount = strategy.detail.status.delivery.getRestAmount()
    if let oldVal = frozenAmounts[tokenType] {
        frozenAmounts[tokenType] = oldVal + restAmount
    } else {
        frozenAmounts[tokenType] = restAmount
    }

    let restShare = strategy.detail.status.delivery.maxClaimableShares - strategy.detail.status.delivery.claimedShares
    if let oldVal = frozenShares[tokenType] {
        frozenShares[tokenType] = oldVal + restShare
    } else {
        frozenShares[tokenType] = restShare
    }
  }

  // FTs
  let ftTypes = treasury.getTreasuryAssets(isNFT: false)
  let balances: {String: UFix64} = {}
  for tokenType in ftTypes {
    let one = treasury.getTreasuryTokenBalance(type: tokenType) ?? panic("Missing token vault.")
    let frozen = frozenAmounts[tokenType] ?? 0.0
    balances[tokenType.identifier] = one.balance - frozen
  }

  // NFTs
  let nftTypes = treasury.getTreasuryAssets(isNFT: true)
  let ids: {String: [UInt64]} = {}
  for tokenType in nftTypes {
    let one = treasury.getTreasuryNFTCollection(type: tokenType) ?? panic("Missing nft.")
    let existIds = one.getIDs()
    if existIds.length > 0 {
      let frozenShares = frozenShares[tokenType] ?? 0
      ids[tokenType.identifier] = frozenShares == 0 ? existIds : existIds.slice(from: 0, upTo: Int(frozenShares))
    }
  }

  return Result(
    strategies, 
    FLOATEventSeriesViews.TreasuryData(balances: balances, ids: ids),
    totalScore,
    consumableScore,
  )
}

pub struct Result {
  pub let strategies: [FLOATEventSeries.StrategyQueryResultWithUser]
  pub let available: FLOATEventSeriesViews.TreasuryData?
  // user score
  pub let userTotalScore: UInt64?
  pub let userConsumableScore: UInt64?

  init(
    _ strategies: [FLOATEventSeries.StrategyQueryResultWithUser],
    _ available: FLOATEventSeriesViews.TreasuryData?,
    _ totalScore: UInt64?,
    _ consumableScore: UInt64?,
  ) {
    self.strategies = strategies
    self.available = available
    self.userTotalScore = totalScore
    self.userConsumableScore = consumableScore
  }
}