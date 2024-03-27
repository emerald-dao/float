import "FLOAT"

access(all) fun main(eventId: UInt64, hostAddress: Address, accountAddress: Address): Bool {
  let floatEventCollection = getAccount(hostAddress).capabilities.borrow<&FLOAT.FLOATEvents>(FLOAT.FLOATEventsPublicPath)
                              ?? panic("Could not borrow the FLOAT Events Collection from the account.")
  let floatEventPublic = floatEventCollection.borrowPublicEventRef(eventId: eventId)

  return floatEventPublic!.userHasClaimed(address: accountAddress)
}