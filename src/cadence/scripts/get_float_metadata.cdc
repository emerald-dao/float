import FLOAT from "../FLOAT.cdc"
import MetadataViews from "../MetadataViews.cdc"

pub fun main(account: Address, id: UInt64): MetadataViews.FLOATMetadataView? {
  let nftCollection = getAccount(account).getCapability(FLOAT.FLOATCollectionPublicPath)
                        .borrow<&FLOAT.Collection{MetadataViews.ResolverCollection}>()
                        ?? panic("Could not borrow the Collection from the account.")
  let nft = nftCollection.borrowViewResolver(id: id)
  if let metadata = nft.resolveView(Type<MetadataViews.FLOATMetadataView>()) {
    return metadata as! MetadataViews.FLOATMetadataView
  }

  return nil
}
