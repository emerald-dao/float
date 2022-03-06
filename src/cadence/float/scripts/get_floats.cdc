import FLOAT from "../FLOAT.cdc"
import MetadataViews from "../../core-contracts/MetadataViews.cdc"
pub fun main(account: Address): {UFix64: CombinedMetadata} {
  let floatCollection = getAccount(account).getCapability(FLOAT.FLOATCollectionPublicPath)
                        .borrow<&FLOAT.Collection{MetadataViews.ResolverCollection}>()
                        ?? panic("Could not borrow the Collection from the account.")
  let ids = floatCollection.getIDs()
  var returnVal: {UFix64: CombinedMetadata} = {}
  for id in ids {
    let resolver = floatCollection.borrowViewResolver(id: id)
    if let floatView = resolver.resolveView(Type<FLOAT.FLOATMetadata>()) {
      let float = floatView as! FLOAT.FLOATMetadata

      let eventView = resolver.resolveView(Type<FLOAT.FLOATEventMetadata>()) 
      let event = eventView as! FLOAT.FLOATEventMetadata?
      returnVal[float.dateReceived] = CombinedMetadata(_float: float, _event: event)
    }
  }

  return returnVal
}

pub struct CombinedMetadata {
    pub let float: FLOAT.FLOATMetadata
    pub let event: FLOAT.FLOATEventMetadata?

    init(
        _float: FLOAT.FLOATMetadata,
        _event:FLOAT.FLOATEventMetadata?
    ) {
        self.float = _float
        self.event = _event
    }
}