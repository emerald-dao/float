import FLOAT from "../FLOAT.cdc"
import FLOATMetadataViews from "../FLOATMetadataViews.cdc"

pub fun main(account: Address, eventId: UInt64): {Address: FLOATMetadataViews.TokenIdentifier} {
  let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                              .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                              ?? panic("Could not borrow the FLOAT Events Collection from the account.")
  return floatEventCollection.borrowPublicEventRef(eventId: eventId).getClaimed()
}