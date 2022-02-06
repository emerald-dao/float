import FLOAT from "../FLOAT.cdc"
import MetadataViews from "../MetadataViews.cdc"

pub fun main(account: Address, id: UInt64): MetadataViews.FLOATEventMetadataView? {
  let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                              .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, MetadataViews.ResolverCollection}>()
                              ?? panic("Could not borrow the FLOAT Events Collection from the account.")
  let floatEvent =  floatEventCollection.borrowViewResolver(id: id)

  if let metadata = floatEvent.resolveView(Type<MetadataViews.FLOATEventMetadataView>()) {
    return metadata as! MetadataViews.FLOATEventMetadataView
  }
  return nil
}
