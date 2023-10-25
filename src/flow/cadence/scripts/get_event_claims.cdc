import FLOAT from "../FLOAT.cdc"

pub fun main(account: Address, eventId: UInt64): [FLOAT.TokenIdentifier] {
  let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                              .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                              ?? panic("Could not borrow the FLOAT Events Collection from the account.")
  let event = floatEventCollection.borrowPublicEventRef(eventId: eventId)!
  let claims: [FLOAT.TokenIdentifier] = event.getClaims().values

  return claims
}