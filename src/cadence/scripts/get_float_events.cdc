import FLOAT from "../FLOAT.cdc"
import MetadataViews from "../core-contracts/MetadataViews.cdc"
import FLOATMetadataViews from "../FLOATMetadataViews.cdc"

pub fun main(account: Address): {String: FLOATMetadataViews.FLOATEventMetadataView} {
  let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                              .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, MetadataViews.ResolverCollection}>()
                              ?? panic("Could not borrow the FLOAT Events Collection from the account.")
  let floatEvents: [UInt64] = floatEventCollection.getIDs()
  let returnVal: {String: FLOATMetadataViews.FLOATEventMetadataView} = {}

  for id in floatEvents {
    let view = floatEventCollection.borrowViewResolver(id: id)
    if var metadata = view.resolveView(Type<FLOATMetadataViews.FLOATEventMetadataView>()) {
      var floatEvent = metadata as! FLOATMetadataViews.FLOATEventMetadataView
      returnVal[floatEvent.name] = floatEvent
    }
  }
  return returnVal
}
