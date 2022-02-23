import FLOAT from "../FLOAT.cdc"
import FLOATMetadataViews from "../FLOATMetadataViews.cdc"

pub fun main(hostAddress: Address, eventId: UInt64, accountAddress: Address): FLOATMetadataViews.TokenIdentifier? {
  let floatEventCollection = getAccount(hostAddress).getCapability(FLOAT.FLOATEventsPublicPath)
                              .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                              ?? panic("Could not borrow the FLOAT Events Collection from the account.")
  let floatEventPublic = floatEventCollection.borrowPublicEventRef(eventId: eventId)

  return floatEventPublic.hasClaimed(account: accountAddress)
}