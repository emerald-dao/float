import MetadataViews from "../../core-contracts/MetadataViews.cdc"
import FLOATEventSeries from "../FLOATEventSeries.cdc"
import FLOATEventSeriesViews from "../FLOATEventSeriesViews.cdc"

pub fun main(
  page: UInt64,
  limit: UInt64,
  isTreasuryAvailable: Bool
): QueryResult {
  let global = FLOATEventSeries.borrowEventSeriesGlobal()
  let seriesIdentifiers = global.querySeries(page: page, limit: limit, isTreasuryAvailable: isTreasuryAvailable)

  let returnVal: {UInt64: FLOATEventSeriesViews.EventSeriesMetadata} = {}
  for seriesInfo in seriesIdentifiers {
    let builderRef = getAccount(seriesInfo.host)
      .getCapability(FLOATEventSeries.FLOATEventSeriesBuilderPublicPath)
      .borrow<&FLOATEventSeries.EventSeriesBuilder{FLOATEventSeries.EventSeriesBuilderPublic, MetadataViews.ResolverCollection}>()
    if builderRef == nil {
      continue
    }
    if let eventSeries = builderRef!.borrowEventSeriesPublic(seriesId: seriesInfo.id) {
      let resolver = builderRef!.borrowViewResolver(id: seriesInfo.id)
      returnVal[eventSeries.sequence] = FLOATEventSeriesViews.EventSeriesMetadata(eventSeries, resolver)
    }
  }

  let total = global.getTotalAmount(isTreasuryAvailable: isTreasuryAvailable)
  
  return QueryResult(returnVal, total)
}

pub struct QueryResult {
  pub let total: Int
  pub let result: {UInt64: FLOATEventSeriesViews.EventSeriesMetadata}

  init(_ result: {UInt64: FLOATEventSeriesViews.EventSeriesMetadata}, _ total: Int) {
    self.result = result
    self.total = total
  }
}