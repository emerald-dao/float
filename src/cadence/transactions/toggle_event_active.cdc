import FLOAT from "../FLOAT.cdc"

transaction(id: UInt64) {

  let FLOATEvent: &FLOAT.FLOATEvent

  prepare(acct: AuthAccount) {
    let FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                        ?? panic("Could not borrow the FLOATEvents from the signer.")
    self.FLOATEvent = FLOATEvents.getEvent(id: id)
  }

  execute {
    self.FLOATEvent.toggleActive()
    log("Toggled the FLOAT Event.")
  }
}
