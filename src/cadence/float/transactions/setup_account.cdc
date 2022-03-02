import FLOAT from "../FLOAT.cdc"
import NonFungibleToken from "../../core-contracts/NonFungibleToken.cdc"
import MetadataViews from "../../core-contracts/MetadataViews.cdc"

transaction {

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
  }

  execute {
    log("Finished setting up the account for FLOATs.")
  }
}
