import "FLOAT"

access(all) fun main(account: Address, eventId: UInt64): [FLOAT.TokenIdentifier] {
  let floatEventCollection = getAccount(account).capabilities.borrow<&FLOAT.FLOATEvents>(FLOAT.FLOATEventsPublicPath)
                              ?? panic("Could not borrow the FLOAT Events Collection from the account.")
  let eventRef = floatEventCollection.borrowPublicEventRef(eventId: eventId)!
  let claims: [FLOAT.TokenIdentifier] = eventRef.getClaims().values

  return claims
}