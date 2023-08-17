import FLOAT from "../FLOAT.cdc"

transaction(eventId: UInt64) {

  let FLOATEvents: &FLOAT.FLOATEvents

  prepare(acct: AuthAccount) {
    self.FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                        ?? panic("Could not borrow the FLOATEvents from the signer.")
  }

  execute {
    let floatEvent = self.FLOATEvents.borrowEventRef(eventId: eventId) ?? panic("This event does not exist.")
    floatEvent.toggleClaimable()
  }
}