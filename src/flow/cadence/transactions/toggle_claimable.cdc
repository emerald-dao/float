import "FLOAT"

transaction(eventId: UInt64) {

  let FLOATEvents: auth(FLOAT.EventsOwner) &FLOAT.FLOATEvents

  prepare(account: auth(Storage) &Account) {
    self.FLOATEvents = account.storage.borrow<auth(FLOAT.EventsOwner) &FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                        ?? panic("Could not borrow the FLOATEvents from the signer.")
  }

  execute {
    let floatEvent = self.FLOATEvents.borrowEventRef(eventId: eventId) ?? panic("This event does not exist.")
    floatEvent.toggleClaimable()
  }
}