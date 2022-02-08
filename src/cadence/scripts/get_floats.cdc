import FLOAT from "../FLOAT.cdc"
import MetadataViews from "../core-contracts/MetadataViews.cdc"
import FLOATMetadataViews from "../FLOATMetadataViews.cdc"

pub fun main(account: Address): [FLOATMetadataViews.FLOATMetadataView] {
  let nftCollection = getAccount(account).getCapability(FLOAT.FLOATCollectionPublicPath)
                        .borrow<&FLOAT.Collection{MetadataViews.ResolverCollection}>()
                        ?? panic("Could not borrow the Collection from the account.")
  let floats = nftCollection.getIDs()
  var returnVal: [FLOATMetadataViews.FLOATMetadataView] = []
  for id in floats {
    let view = nftCollection.borrowViewResolver(id: id)
    if var metadata = view.resolveView(Type<FLOATMetadataViews.FLOATMetadataView>()) {
      var float = metadata as! FLOATMetadataViews.FLOATMetadataView
      returnVal.append(float)
    }
  }

  return returnVal
}
