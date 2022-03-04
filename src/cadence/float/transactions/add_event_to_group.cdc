import FLOAT from "../FLOAT.cdc"

transaction(forHost: Address?, groupName: String, eventId: UInt64) {

  let FLOATEvents: &FLOAT.FLOATEvents

  prepare(acct: AuthAccount) {
    if let fromHost = forHost {
      let FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                        ?? panic("Could not borrow the FLOATEvents from the signer.")
      self.FLOATEvents = FLOATEvents.borrowSharedRef(fromHost: fromHost)
    } else {
      self.FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                        ?? panic("Could not borrow the FLOATEvents from the signer.")
    }
  }

  execute {
    self.FLOATEvents.addEventToGroup(groupName: groupName, eventId: eventId)
    log("Added an event to a group.")
  }
}