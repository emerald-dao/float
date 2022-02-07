import FLOAT from "../FLOAT.cdc"
import NonFungibleToken from "../core-contracts/NonFungibleToken.cdc"

transaction(id: UInt64, recipient: Address) {
 
  let FLOATEvents: &FLOAT.FLOATEvents
  let RecipientCollection: &FLOAT.Collection{NonFungibleToken.CollectionPublic}

  prepare(signer: AuthAccount) {
    self.FLOATEvents = signer.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                          ?? panic("Could not borrow the signer's FLOAT Events resource.")
    self.RecipientCollection = getAccount(recipient).getCapability(FLOAT.FLOATCollectionPublicPath)
                                .borrow<&FLOAT.Collection{NonFungibleToken.CollectionPublic}>()
                                ?? panic("Could not get the public FLOAT Collection from the recipient.")
  }

  execute {
    self.FLOATEvents.distributeDirectly(id: id, recipient: self.RecipientCollection)
    log("Distributed the FLOAT.")
  }
}
 