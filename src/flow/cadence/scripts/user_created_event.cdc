import "FLOAT"

access(all) fun main(user: Address, eventId: UInt64): Bool {
  let authAccount = getAuthAccount<auth(Storage) &Account>(user)
  if let floatEventCollection = authAccount.storage.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath) {
    return floatEventCollection.getIDs().contains(eventId)
  }

  return false
}