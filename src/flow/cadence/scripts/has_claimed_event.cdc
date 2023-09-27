import FLOAT from "../FLOAT.cdc"

pub fun main(eventId: UInt64, hostAddress: Address, accountAddress: Address): Bool {
  let floatEventCollection = getAccount(hostAddress).getCapability(FLOAT.FLOATEventsPublicPath)
                              .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                              ?? panic("Could not borrow the FLOAT Events Collection from the account.")
  let floatEventPublic = floatEventCollection.borrowPublicEventRef(eventId: eventId)

  return floatEventPublic!.userHasClaimed(address: accountAddress)
}