import FLOAT from "../FLOAT.cdc"

pub fun main(host: Address, eventId: UInt64): [[{FLOAT.IVerifier}]] {
  let floatEventCollection = getAccount(host).getCapability(FLOAT.FLOATEventsPublicPath)
      .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
      ?? panic("Could not borrow the FLOAT Events Collection from the account.")
  let eventPublicRef = floatEventCollection.borrowPublicEventRef(eventId: eventId) ?? panic("This event does not exist in the account")
  let verifiers = eventPublicRef.getVerifiers()
  return verifiers.values
}
