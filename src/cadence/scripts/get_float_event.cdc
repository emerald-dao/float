import FLOAT from "../FLOAT.cdc"
import MetadataViews from "../core-contracts/MetadataViews.cdc"
import FLOATMetadataViews from "../FLOATMetadataViews.cdc"

pub fun main(account: Address, id: UInt64): FLOATMetadataViews.FLOATEventMetadataView? {
  let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                              .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, MetadataViews.ResolverCollection}>()
                              ?? panic("Could not borrow the FLOAT Events Collection from the account.")
  let floatEvent = floatEventCollection.borrowViewResolver(id: id)

  if let metadata = floatEvent.resolveView(Type<FLOATMetadataViews.FLOATEventMetadataView>()) {
    return metadata as! FLOATMetadataViews.FLOATEventMetadataView
  }
  return nil
}
