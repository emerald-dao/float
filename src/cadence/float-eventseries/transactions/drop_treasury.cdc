import MetadataViews from "../../core-contracts/MetadataViews.cdc"
import FungibleToken from "../../core-contracts/FungibleToken.cdc"
import FLOATEventSeries from "../FLOATEventSeries.cdc"

transaction(
  seriesId: UInt64
) {
  let eventSeries: &FLOATEventSeries.EventSeries

  prepare(acct: AuthAccount) {
    // SETUP Event Series builder resource, link public and private
    if acct.borrow<&FLOATEventSeries.EventSeriesBuilder>(from: FLOATEventSeries.FLOATEventSeriesBuilderStoragePath) == nil {
      acct.save(<- FLOATEventSeries.createEventSeriesBuilder(), to: FLOATEventSeries.FLOATEventSeriesBuilderStoragePath)
      acct.link<&FLOATEventSeries.EventSeriesBuilder{FLOATEventSeries.EventSeriesBuilderPublic, MetadataViews.ResolverCollection}>
          (FLOATEventSeries.FLOATEventSeriesBuilderPublicPath, target: FLOATEventSeries.FLOATEventSeriesBuilderStoragePath)
    }

    let serieshelf = acct.borrow<&FLOATEventSeries.EventSeriesBuilder>(from: FLOATEventSeries.FLOATEventSeriesBuilderStoragePath)
      ?? panic("Could not borrow the Event Series builder.")
    
    // event series
    self.eventSeries = serieshelf.borrowEventSeries(seriesId: seriesId)
      ?? panic("Could not borrow the event series private.")
  }

  execute {
    let treasury = self.eventSeries.borrowTreasury()
    treasury.dropTreasury()

    log("Treasury have been dropped from a FLOAT EventSeries.")
  }
}
