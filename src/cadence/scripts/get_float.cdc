import FLOAT from "../FLOAT.cdc"

pub fun main(account: Address, id: UInt64): &FLOAT.NFT {
  let nftCollection = getAccount(account).getCapability(FLOAT.FLOATCollectionPublicPath)
                        .borrow<&FLOAT.Collection{FLOAT.CollectionPublic}>()
                        ?? panic("Could not borrow the Collection from the account.")
  return nftCollection.borrowFLOAT(id: id)
}