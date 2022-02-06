import FLOAT from "../FLOAT.cdc"
import MetadataViews from "../MetadataViews.cdc"

pub fun main(account: Address): {String: MetadataViews.FLOATEventMetadataView} {
  let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                              .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, MetadataViews.ResolverCollection}>()
                              ?? panic("Could not borrow the FLOAT Events Collection from the account.")
  let floatEvents: [UInt64] = floatEventCollection.getIDs()
  let returnVal: {String: MetadataViews.FLOATEventMetadataView} = {}

  for id in floatEvents {
    let view = floatEventCollection.borrowViewResolver(id: id)
    if var metadata = view.resolveView(Type<MetadataViews.FLOATEventMetadataView>()) {
      var floatEvent = metadata as! MetadataViews.FLOATEventMetadataView
      returnVal[floatEvent.name] = floatEvent
    }
  }
  return returnVal
}
