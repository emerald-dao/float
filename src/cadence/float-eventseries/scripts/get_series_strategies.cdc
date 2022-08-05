import NonFungibleToken from "../../core-contracts/NonFungibleToken.cdc"
import FungibleToken from "../../core-contracts/FungibleToken.cdc"
import FLOATEventSeries from "../FLOATEventSeries.cdc"
import FLOATEventSeriesViews from "../FLOATEventSeriesViews.cdc"

pub fun main(
  host: Address,
  id: UInt64,
  includingAvailables: Bool
): Result {

  let builderRef = getAccount(host)
    .getCapability(FLOATEventSeries.FLOATEventSeriesBuilderPublicPath)
    .borrow<&FLOATEventSeries.EventSeriesBuilder{FLOATEventSeries.EventSeriesBuilderPublic}>()
    ?? panic("Missing FLOAT EventSeries Builder.")
  let eventSeries = builderRef!.borrowEventSeries(seriesId: id)
    ?? panic("Missing FLOAT EventSeries Builder.")
  let treasury = eventSeries.borrowTreasury()

  let strategies = treasury.getStrategies(states: [
      FLOATEventSeries.StrategyState.preparing,
      FLOATEventSeries.StrategyState.opening,
      FLOATEventSeries.StrategyState.claimable
  ])

  if !includingAvailables {
    return Result(strategies, nil)
  }

  // calc frozen data
  var frozenAmounts: {Type: UFix64} = {}
  var frozenShares: {Type: UInt64} = {}
  for strategy in strategies {
    let tokenType = strategy.status.delivery.deliveryTokenType

    let restAmount = strategy.status.delivery.getRestAmount()
    if let oldVal = frozenAmounts[tokenType] {
        frozenAmounts[tokenType] = oldVal + restAmount
    } else {
        frozenAmounts[tokenType] = restAmount
    }

    let restShare = strategy.status.delivery.maxClaimableShares - strategy.status.delivery.claimedShares
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

  return Result(strategies, FLOATEventSeriesViews.TreasuryData(balances: balances, ids: ids))
}

pub struct Result {
  pub let available: FLOATEventSeriesViews.TreasuryData?
  pub let strategies: [FLOATEventSeries.StrategyDetail]

  init(_ strategies: [FLOATEventSeries.StrategyDetail], _ available: FLOATEventSeriesViews.TreasuryData?) {
    self.strategies = strategies
    self.available = available
  }
}