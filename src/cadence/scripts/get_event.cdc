import FLOAT from "../FLOAT.cdc"

pub fun main(account: Address, eventId: UInt64): &FLOAT.FLOATEvent{FLOAT.FLOATEventPublic} {
  let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                              .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                              ?? panic("Could not borrow the FLOAT Events Collection from the account.")
  return floatEventCollection.borrowPublicEventRef(eventId: eventId)
}