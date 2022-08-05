import NonFungibleToken from "../../core-contracts/NonFungibleToken.cdc"
import FungibleToken from "../../core-contracts/FungibleToken.cdc"
import FLOATEventSeries from "../FLOATEventSeries.cdc"
import FLOATEventSeriesViews from "../FLOATEventSeriesViews.cdc"

pub fun main(
  host: Address,
  id: UInt64,
): FLOATEventSeriesViews.TreasuryData {

  let builderRef = getAccount(host)
    .getCapability(FLOATEventSeries.FLOATEventSeriesBuilderPublicPath)
    .borrow<&FLOATEventSeries.EventSeriesBuilder{FLOATEventSeries.EventSeriesBuilderPublic}>()
    ?? panic("Missing FLOAT EventSeries Builder.")

  let eventSeries = builderRef!.borrowEventSeries(seriesId: id)
    ?? panic("Missing FLOAT EventSeries Builder.")

  let treasury = eventSeries.borrowTreasury()

  // FTs
  let ftTypes = treasury.getTreasuryAssets(isNFT: false)
  let balances: {String: UFix64} = {}
  for tokenType in ftTypes {
    let one = treasury.getTreasuryTokenBalance(type: tokenType) ?? panic("Missing token vault.")
    balances[tokenType.identifier] = one.balance
  }

  // NFTs
  let nftTypes = treasury.getTreasuryAssets(isNFT: true)
  let ids: {String: [UInt64]} = {}
  for tokenType in nftTypes {
    let one = treasury.getTreasuryNFTCollection(type: tokenType) ?? panic("Missing nft.")
    let existIds = one.getIDs()
    if existIds.length > 0 {
      let identifier = one.borrowNFT(id: existIds[0]).getType().identifier
      ids[identifier] = existIds
    }
  }

  return FLOATEventSeriesViews.TreasuryData(balances: balances, ids: ids)
}
