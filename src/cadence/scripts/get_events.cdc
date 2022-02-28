import FLOAT from "../FLOAT.cdc"
import MetadataViews from "../core-contracts/MetadataViews.cdc"

pub fun main(account: Address): {String: FLOAT.FLOATEventMetadata} {
  let floatEventCollection = getAccount(account).getCapability(FLOAT.FLOATEventsPublicPath)
                              .borrow<&FLOAT.FLOATEvents{MetadataViews.ResolverCollection}>()
                              ?? panic("Could not borrow the FLOAT Events Collection from the account.")
  let floatEvents: [UInt64] = floatEventCollection.getIDs()
  let returnVal: {String: FLOAT.FLOATEventMetadata} = {}

  for eventId in floatEvents {
    let resolved = floatEventCollection.borrowViewResolver(id: eventId)
    if let view = resolved.resolveView(Type<FLOAT.FLOATEventMetadata>()) {
      let metadata = view as! FLOAT.FLOATEventMetadata
      returnVal[metadata.name] = metadata
    }
  }
  return returnVal
}