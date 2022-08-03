import MetadataViews from "../../core-contracts/MetadataViews.cdc"
import FLOATEventSeries from "../FLOATEventSeries.cdc"
import FLOATEventSeriesViews from "../FLOATEventSeriesViews.cdc"

pub fun main(
  host: Address,
  id: UInt64,
):  EventSeriesMetadata? {

  let builderRef = getAccount(host)
    .getCapability(FLOATEventSeries.FLOATEventSeriesBuilderPublicPath)
    .borrow<&FLOATEventSeries.EventSeriesBuilder{FLOATEventSeries.EventSeriesBuilderPublic, MetadataViews.ResolverCollection}>()
  
  if builderRef == nil {
    return nil
  }

  let eventSeries = builderRef!.borrowEventSeries(seriesId: id)
  let resolver = builderRef!.borrowViewResolver(id: id)
  if eventSeries == nil || resolver == nil {
    return nil
  }

  return EventSeriesMetadata(eventSeries!, resolver)
}

// EventSeries Metadata
pub struct EventSeriesMetadata {
  pub let id: UInt64
  pub let sequence: UInt64
  pub let display: MetadataViews.Display?
  pub let slots: [FLOATEventSeriesViews.SeriesSlotInfo]

  init(
    _ eventSeries: &FLOATEventSeries.EventSeries{FLOATEventSeries.EventSeriesPublic},
    _ resolver: &{MetadataViews.Resolver},
  ) {
    self.id = eventSeries.uuid
    self.sequence = eventSeries.sequence
    self.display = MetadataViews.getDisplay(resolver)
    self.slots = []
    // fill slots
    let slots = eventSeries.getSlots()
    for slot in slots {
      self.slots.append(FLOATEventSeriesViews.SeriesSlotInfo(
        slot.getIdentifier(),
        slot.isEventRequired()
      ))
    }
  }
}