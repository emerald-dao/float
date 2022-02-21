import FLOAT from "../FLOAT.cdc"

transaction (fromHost: Address) {

  let FLOATEvents: &FLOAT.FLOATEvents

  prepare(acct: AuthAccount) {
    self.FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("The signer does not have a FLOAT Events.")
  }

  execute {
    self.FLOATEvents.takeSharing(fromHost: fromHost)
    log("Removes sharing withHost.")
  }
}
