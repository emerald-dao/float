import FLOATEventSeries from "./FLOATEventSeries.cdc"
import MetadataViews from "../core-contracts/MetadataViews.cdc"

pub contract FLOATEventSeriesViews {

  // EventSeries Slot information
  pub struct SeriesSlotInfo {
    pub let event: FLOATEventSeries.EventIdentifier?
    pub let required: Bool

    init(
      _ identifier: FLOATEventSeries.EventIdentifier?,
      _ isRequired: Bool,
    ) {
      self.event = identifier
      self.required = isRequired
    }
  }

  // EventSeries Metadata
  pub struct EventSeriesMetadata {
    pub let host: Address
    pub let id: UInt64
    pub let sequence: UInt64
    pub let display: MetadataViews.Display?
    pub let slots: [SeriesSlotInfo]
    pub let extra: {String: AnyStruct}

    init(
      _ eventSeries: &FLOATEventSeries.EventSeries{FLOATEventSeries.EventSeriesPublic},
      _ resolver: &{MetadataViews.Resolver},
    ) {
      self.host = eventSeries.owner!.address
      self.id = eventSeries.uuid
      self.sequence = eventSeries.sequence
      self.display = MetadataViews.getDisplay(resolver)
      self.slots = []
      // fill slots
      let slots = eventSeries.getSlots()
      for slot in slots {
        self.slots.append(SeriesSlotInfo(
          slot.getIdentifier(),
          slot.isEventRequired()
        ))
      }
      self.extra = {}
    }
  }

  // Treasury return data
  pub struct TreasuryData {
    pub let tokenBalances: {String: UFix64}
    pub let collectionIDs: {String: [UInt64]}

    init(balances: {String: UFix64}, ids: {String: [UInt64]}) {
      self.tokenBalances = balances
      self.collectionIDs = ids
    }
  }
}
