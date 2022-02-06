import FLOAT from "../FLOAT.cdc"
import MetadataViews from "../MetadataViews.cdc"
import NonFungibleToken from "../NonFungibleToken.cdc"

pub fun main(account: Address): [MetadataViews.FLOATMetadataView] {
  let nftCollection = getAccount(account).getCapability(FLOAT.FLOATCollectionPublicPath)
                        .borrow<&FLOAT.Collection{NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>()
                        ?? panic("Could not borrow the Collection from the account.")
  let floats = nftCollection.getIDs()
  var returnVal: [MetadataViews.FLOATMetadataView] = []
  for id in floats {
    let view = nftCollection.borrowViewResolver(id: id)
    if var metadata = view.resolveView(Type<MetadataViews.FLOATMetadataView>()) {
      var float = metadata as! MetadataViews.FLOATMetadataView
      returnVal.append(float)
    }
  }

  return returnVal
}
