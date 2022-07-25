import MetadataViews from "../../core-contracts/MetadataViews.cdc"
import FLOATEventSeries from "../FLOATEventSeries.cdc"

pub fun main(
  host: Address
):  {UInt64: EventSeriesMetadata} {

  let collection = getAccount(host)
    .getCapability(FLOATEventSeries.FLOATEventSeriesBuilderPublicPath)
    .borrow<&FLOATEventSeries.EventSeriesBuilder{FLOATEventSeries.EventSeriesBuilderPublic, MetadataViews.ResolverCollection}>()
                              ?? panic("Could not borrow the FLOAT EventSeries Collection from the account.")
  let eventSeriesIds: [UInt64] = collection.getIDs() 

  let returnVal: {UInt64: EventSeriesMetadata} = {}
  for oneId in eventSeriesIds {
    let eventSeries = collection.borrowEventSeries(seriesId: oneId)
      ?? panic("This event series does not exist in the account.")
    let resolver = collection.borrowViewResolver(id: oneId)
    returnVal[eventSeries.sequence] = EventSeriesMetadata(eventSeries, resolver)
  }
  return returnVal
}

// EventSeries Metadata
pub struct EventSeriesMetadata {
    pub let id: UInt64
    pub let sequence: UInt64
    pub let display: MetadataViews.Display?

    init(
      _ eventSeries: &FLOATEventSeries.EventSeries{FLOATEventSeries.EventSeriesPublic},
      _ resolver: &{MetadataViews.Resolver},
    ) {
      self.id = eventSeries.uuid
      self.sequence = eventSeries.sequence
      self.display = MetadataViews.getDisplay(resolver)
    }
}