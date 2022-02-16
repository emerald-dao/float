import FLOAT from "../FLOAT.cdc"
import NonFungibleToken from "../core-contracts/NonFungibleToken.cdc"
import MetadataViews from "../core-contracts/MetadataViews.cdc"

transaction (receiver: Address) {

  let FLOATEventsCapability: Capability<&FLOAT.FLOATEvents>
  let ReceiverFLOATEvents: &FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}

  prepare(acct: AuthAccount) {

    pre{ 
      acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath) != nil : "FLOATEvent Collection is not created."
    }

    // set up the FLOAT Collection (where users will store their FLOATs) if they havent get one
    if acct.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath) == nil {
      acct.save(<- FLOAT.createEmptyCollection(), to: FLOAT.FLOATCollectionStoragePath)
      acct.link<&FLOAT.Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>
              (FLOAT.FLOATCollectionPublicPath, target: FLOAT.FLOATCollectionStoragePath)
    }

    // link the FLOATEvents as private capability to enable passing
    acct.link<&FLOAT.FLOATEvents>(FLOAT.FLOATEventsPrivatePath, target: FLOAT.FLOATEventsStoragePath)
    self.FLOATEventsCapability = acct.getCapability<&FLOAT.FLOATEvents>(FLOAT.FLOATEventsPrivatePath)

    self.ReceiverFLOATEvents = getAccount(receiver).getCapability(FLOAT.FLOATEventsPublicPath)
                                .borrow<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic}>() 
                                ?? panic("This Capability does not exist")
  }

  execute {
    self.ReceiverFLOATEvents.addSharedMinter(minter: self.FLOATEventsCapability)
    log("The Receiver now has access to the signer's FLOATEvents.")
  }
}
