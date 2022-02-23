import FLOAT from "../FLOAT.cdc"

transaction(eventId: UInt64) {

  let FLOATEvent: &FLOAT.FLOATEvent

  prepare(acct: AuthAccount) {
    let FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                        ?? panic("Could not borrow the FLOATEvents from the signer.")
    self.FLOATEvent = FLOATEvents.borrowEventRef(eventId: eventId)
  }

  execute {
    self.FLOATEvent.toggleTransferrable()
    log("Toggled the FLOAT Event.")
  }
}