import FLOAT from "../FLOAT.cdc"
import NonFungibleToken from "../../utility/NonFungibleToken.cdc"

pub fun main(account: Address): [UInt64] {
  let nftCollection = getAccount(account).getCapability(FLOAT.FLOATCollectionPublicPath)
                        .borrow<&FLOAT.Collection{NonFungibleToken.CollectionPublic}>()
                        ?? panic("Could not borrow the Collection from the account.")
  return nftCollection.getIDs()
}
