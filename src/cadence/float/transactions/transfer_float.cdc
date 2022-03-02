import FLOAT from "../FLOAT.cdc"
import NonFungibleToken from "../../core-contracts/NonFungibleToken.cdc"

transaction(id: UInt64, recipient: Address) {

  let Collection: &FLOAT.Collection
  let RecipientCollection: &FLOAT.Collection{NonFungibleToken.CollectionPublic}

  prepare(acct: AuthAccount) {
    self.Collection = acct.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath)
                        ?? panic("Could not get the Collection from the signer.")
    self.RecipientCollection = getAccount(recipient).getCapability(FLOAT.FLOATCollectionPublicPath)
                              .borrow<&FLOAT.Collection{NonFungibleToken.CollectionPublic}>()
                              ?? panic("Could not borrow the recipient's public FLOAT Collection.")
  }

  execute {
    self.Collection.transfer(withdrawID: id, recipient: self.RecipientCollection)
    log("Transferred the FLOAT.")
  }
}