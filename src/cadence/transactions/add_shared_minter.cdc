import FLOAT from "../FLOAT.cdc"
import NonFungibleToken from "../core-contracts/NonFungibleToken.cdc"
import MetadataViews from "../core-contracts/MetadataViews.cdc"

transaction (receiver: Address) {

  let ReceiverFLOATEvents: &FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}
  let GiverFLOATEvents: &FLOAT.FLOATEvents
  
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
      acct.link<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, MetadataViews.ResolverCollection}>
                (FLOAT.FLOATEventsPublicPath, target: FLOAT.FLOATEventsStoragePath)
    }

    self.ReceiverFLOATEvents = getAccount(receiver).getCapability(FLOAT.FLOATEventsPublicPath)
                                .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>() 
                                ?? panic("Cannot borrow the public FLOAT Events from forHost")
    self.GiverFLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                              ?? panic("The signer does not have a FLOAT Events.")
  }

  execute {
    self.GiverFLOATEvents.giveSharing(toHost: self.ReceiverFLOATEvents)
    log("The Receiver now has access to the signer's FLOATEvents.")
  }
}
