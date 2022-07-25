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
}
