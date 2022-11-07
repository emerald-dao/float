import MetadataViews from "../../core-contracts/MetadataViews.cdc"
import FLOATEventSeries from "../FLOATEventSeries.cdc"

transaction(
  seriesId: UInt64,
  certHosts: [Address],
  certEventIds: [UInt64],
) {
  let eventSeries: &FLOATEventSeries.EventSeries

  prepare(acct: AuthAccount) {
    // SETUP Event Series builder resource, link public and private
    if acct.borrow<&FLOATEventSeries.EventSeriesBuilder>(from: FLOATEventSeries.FLOATEventSeriesBuilderStoragePath) == nil {
      acct.save(<- FLOATEventSeries.createEventSeriesBuilder(), to: FLOATEventSeries.FLOATEventSeriesBuilderStoragePath)
      acct.link<&FLOATEventSeries.EventSeriesBuilder{FLOATEventSeries.EventSeriesBuilderPublic, MetadataViews.ResolverCollection}>
          (FLOATEventSeries.FLOATEventSeriesBuilderPublicPath, target: FLOATEventSeries.FLOATEventSeriesBuilderStoragePath)
    }

    let builder = acct.borrow<&FLOATEventSeries.EventSeriesBuilder>(from: FLOATEventSeries.FLOATEventSeriesBuilderStoragePath)
      ?? panic("Could not borrow the Event Series builder.")
    
    self.eventSeries = builder.borrowEventSeries(seriesId: seriesId)
      ?? panic("Could not borrow the event series private.")
  }

  pre {
    certHosts.length > 0: "host length should be greator then zero"
    certHosts.length == certEventIds.length: "Length of hosts and eventIds should be same."
  }

  execute {
    let events: [FLOATEventSeries.EventIdentifier] = []
    // add events
    let len = certHosts.length
    var cnt: Int = 0
    while cnt < len {
      events.append(FLOATEventSeries.EventIdentifier(certHosts[cnt], certEventIds[cnt]))
      cnt = cnt + 1
    }
    self.eventSeries.syncCertificates(events: events)
    log("Certificates Synced")
  }
}
