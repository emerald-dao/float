import FLOAT from "../FLOAT.cdc"

pub fun main(user: Address, eventId: UInt64): Bool {
  let authAccount: AuthAccount = getAuthAccount(user)
  if let floatEventCollection = authAccount.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath) {
    return floatEventCollection.getIDs().contains(eventId)
  }

  return false
}