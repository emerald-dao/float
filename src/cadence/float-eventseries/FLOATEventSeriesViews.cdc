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
