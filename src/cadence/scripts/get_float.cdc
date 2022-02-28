import FLOAT from "../FLOAT.cdc"
import MetadataViews from "../core-contracts/MetadataViews.cdc"

pub fun main(account: Address, id: UInt64): FLOAT.FLOATMetadata? {
  let floatCollection = getAccount(account).getCapability(FLOAT.FLOATCollectionPublicPath)
                        .borrow<&FLOAT.Collection{MetadataViews.ResolverCollection}>()
                        ?? panic("Could not borrow the Collection from the account.")
  let resolved = floatCollection.borrowViewResolver(id: id)
  if let view = resolved.resolveView(Type<FLOAT.FLOATMetadata>()) {
    return view as! FLOAT.FLOATMetadata
  }
  return nil
}