import FLOAT from "../FLOAT.cdc"
import NonFungibleToken from "../core-contracts/NonFungibleToken.cdc"
import MetadataViews from "../core-contracts/MetadataViews.cdc"

transaction(id: UInt64, host: Address, secret: String?) {
 
  let FLOATEvents: &FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}
  let Collection: &FLOAT.Collection

  prepare(acct: AuthAccount) {
    // set up the FLOAT Collection where users will store their FLOATs
    if acct.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath) == nil {
        acct.save(<- FLOAT.createEmptyCollection(), to: FLOAT.FLOATCollectionStoragePath)
        acct.link<&FLOAT.Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>
                (FLOAT.FLOATCollectionPublicPath, target: FLOAT.FLOATCollectionStoragePath)
    }

    // set up the FLOAT Events where users will store all their created events
    if acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath) == nil {
      acct.save(<- FLOAT.createEmptyFLOATEventCollection(), to: FLOAT.FLOATEventsStoragePath)
      acct.link<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, FLOAT.FLOATEventsSharedMinter, MetadataViews.ResolverCollection}>(FLOAT.FLOATEventsPublicPath, target: FLOAT.FLOATEventsStoragePath)
    }

    self.FLOATEvents = getAccount(host).getCapability(FLOAT.FLOATEventsPublicPath)
                        .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>()
                        ?? panic("Could not borrow the public FLOATEvents from the host.")
    self.Collection = acct.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath)
                        ?? panic("Could not get the Collection from the signer.")
  }

  execute {
    self.FLOATEvents.claim(id: id, recipient: self.Collection, secret: secret)
    log("Claimed the FLOAT.")
  }
}
 