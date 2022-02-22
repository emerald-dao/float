import FLOAT from "../FLOAT.cdc"
import MetadataViews from "../core-contracts/MetadataViews.cdc"
import FLOATMetadataViews from "../FLOATMetadataViews.cdc"
import FLOATVerifiers from "../FLOATVerifiers.cdc"

pub fun main(account: Address, id: UInt64): {FLOAT.IVerifier} {
  let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                              .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, MetadataViews.ResolverCollection}>()
                              ?? panic("Could not borrow the FLOAT Events Collection from the account.")
  return floatEventCollection.getPublicEventRef(id: id).verifier
}