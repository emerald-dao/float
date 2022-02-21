import FLOAT from "../FLOAT.cdc"
import MetadataViews from "../core-contracts/MetadataViews.cdc"
import FLOATMetadataViews from "../FLOATMetadataViews.cdc"

pub fun main(hostAddress: Address, id: UInt64, accountAddress: Address): FLOATMetadataViews.Identifier? {
  let floatEventCollection = getAccount(hostAddress).getCapability(FLOAT.FLOATEventsPublicPath)
                              .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, MetadataViews.ResolverCollection}>()
                              ?? panic("Could not borrow the FLOAT Events Collection from the account.")
  let floatEventPublic = floatEventCollection.getPublicEventRef(id: id)

  return floatEventPublic.hasClaimed(account: accountAddress)
}