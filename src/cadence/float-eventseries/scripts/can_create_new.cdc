import FLOATEventSeries from "../FLOATEventSeries.cdc"
import MetadataViews from "../../core-contracts/MetadataViews.cdc"
import EmeraldPass from "../../core-contracts/EmeraldPass.cdc"

pub fun main(accountAddr: Address): Bool {
  let acct = getAccount(accountAddr)
  let builder = acct.getCapability<&FLOATEventSeries.EventSeriesBuilder{FLOATEventSeries.EventSeriesBuilderPublic, MetadataViews.ResolverCollection}>(FLOATEventSeries.FLOATEventSeriesBuilderPublicPath).borrow()

  // true for never created
  if builder == nil {
    return true
  }

  if EmeraldPass.isActive(user: accountAddr) {
    // true for pass holder
    return true
  } else {
    // true for new user
    return builder!.getIDs().length == 0
  }
}