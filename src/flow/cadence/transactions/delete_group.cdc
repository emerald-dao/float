import FLOAT from "../FLOAT.cdc"

transaction(groupName: String) {

  let FLOATEvents: &FLOAT.FLOATEvents

  prepare(acct: AuthAccount) {
      self.FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                        ?? panic("Could not borrow the FLOATEvents from the signer.")
  }

  execute {
    self.FLOATEvents.deleteGroup(groupName: groupName)
    log("Deleted a Group.")
  }
}
 