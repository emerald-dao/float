import FLOAT from "../FLOAT.cdc"
import NonFungibleToken from "../utility/NonFungibleToken.cdc"

pub fun main(user: Address): Bool {
  return getAccount(user).getCapability<&FLOAT.Collection{NonFungibleToken.CollectionPublic}>(FLOAT.FLOATCollectionPublicPath).borrow() != nil
}