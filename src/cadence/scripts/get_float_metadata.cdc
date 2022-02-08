import FLOAT from "../FLOAT.cdc"
import MetadataViews from "../core-contracts/MetadataViews.cdc"
import FLOATMetadataViews from "../FLOATMetadataViews.cdc"

pub fun main(account: Address, id: UInt64): FLOATMetadataViews.FLOATMetadataView? {
  let nftCollection = getAccount(account).getCapability(FLOAT.FLOATCollectionPublicPath)
                        .borrow<&FLOAT.Collection{MetadataViews.ResolverCollection}>()
                        ?? panic("Could not borrow the Collection from the account.")
  let nft = nftCollection.borrowViewResolver(id: id)
  if let metadata = nft.resolveView(Type<FLOATMetadataViews.FLOATMetadataView>()) {
    return metadata as! FLOATMetadataViews.FLOATMetadataView
  }

  return nil
}
