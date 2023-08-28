import FLOAT from "../FLOAT.cdc"

pub fun main(user: Address): Bool {
  return getAccount(user).getCapability<&FLOAT.Collection{FLOAT.CollectionPublic}>(FLOAT.FLOATCollectionPublicPath).borrow() != nil
}