import FLOAT from "../FLOAT.cdc"
import NonFungibleToken from "../../utility/NonFungibleToken.cdc"

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

  pre {
    self.Collection.borrowFLOAT(id: id) != nil:
      "You do not own this FLOAT."
    self.Collection.borrowFLOAT(id: id)!.getEventMetadata() != nil:
      "Could not borrow the public FLOAT Event data."
    self.Collection.borrowFLOAT(id: id)!.getEventMetadata()!.transferrable:
      "This FLOAT is not giftable on the FLOAT platform."
  }

  execute {
    self.RecipientCollection.deposit(token: <- self.Collection.withdraw(withdrawID: id))
    log("Transferred the FLOAT.")
  }
}