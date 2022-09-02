import MetadataViews from "../../core-contracts/MetadataViews.cdc"
import FLOATEventSeries from "../FLOATEventSeries.cdc"
import FLOATEventSeriesViews from "../FLOATEventSeriesViews.cdc"

pub fun main(
  host: Address,
  id: UInt64,
):  FLOATEventSeriesViews.EventSeriesMetadata? {

  let builderRef = getAccount(host)
    .getCapability(FLOATEventSeries.FLOATEventSeriesBuilderPublicPath)
    .borrow<&FLOATEventSeries.EventSeriesBuilder{FLOATEventSeries.EventSeriesBuilderPublic, MetadataViews.ResolverCollection}>()
  
  if builderRef == nil {
    return nil
  }

  let eventSeries = builderRef!.borrowEventSeriesPublic(seriesId: id)
  let resolver = builderRef!.borrowViewResolver(id: id)
  if eventSeries == nil || resolver == nil {
    return nil
  }

  return FLOATEventSeriesViews.EventSeriesMetadata(eventSeries!, resolver)
}
