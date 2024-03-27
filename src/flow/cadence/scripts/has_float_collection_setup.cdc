import "FLOAT"
import "NonFungibleToken"

access(all) fun main(user: Address): Bool {
  return getAccount(user).capabilities.borrow<&FLOAT.Collection>(FLOAT.FLOATCollectionPublicPath) != nil
}