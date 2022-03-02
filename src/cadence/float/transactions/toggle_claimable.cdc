import FLOAT from "../FLOAT.cdc"

transaction(forHost: Address?, eventId: UInt64) {

  let FLOATEvents: &FLOAT.FLOATEvents
  let FLOATEvent: &FLOAT.FLOATEvent

  prepare(acct: AuthAccount) {
    if let fromHost = forHost {
      let FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                        ?? panic("Could not borrow the FLOATEvents from the signer.")
      self.FLOATEvents = FLOATEvents.borrowSharedRef(fromHost: fromHost)
    } else {
      self.FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                        ?? panic("Could not borrow the FLOATEvents from the signer.")
    }

    self.FLOATEvent = self.FLOATEvents.borrowEventRef(eventId: eventId)
  }

  execute {
    self.FLOATEvent.toggleClaimable()
    log("Toggled the FLOAT Event.")
  }
}