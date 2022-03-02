import FLOAT from "../FLOAT.cdc"
import NonFungibleToken from "../../core-contracts/NonFungibleToken.cdc"
import MetadataViews from "../../core-contracts/MetadataViews.cdc"

transaction(forHost: Address?, eventId: UInt64, recipient: Address) {

	let FLOATEvents: &FLOAT.FLOATEvents
	let FLOATEvent: &FLOAT.FLOATEvent
	let RecipientCollection: &FLOAT.Collection{NonFungibleToken.CollectionPublic}

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

		if let fromHost = forHost {
      let FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                        ?? panic("Could not borrow the FLOATEvents from the signer.")
      self.FLOATEvents = FLOATEvents.borrowSharedRef(fromHost: fromHost)
    } else {
      self.FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                        ?? panic("Could not borrow the FLOATEvents from the signer.")
    }

		self.FLOATEvent = self.FLOATEvents.borrowEventRef(eventId: eventId)
		self.RecipientCollection = getAccount(recipient).getCapability(FLOAT.FLOATCollectionPublicPath)
																.borrow<&FLOAT.Collection{NonFungibleToken.CollectionPublic}>()
																?? panic("Could not get the public FLOAT Collection from the recipient.")
	}

	execute {
		//
		// Give the "recipient" a FLOAT from the event with "id"
		//

		self.FLOATEvent.mint(recipient: self.RecipientCollection)
		log("Distributed the FLOAT.")

		//
		// SOME OTHER ACTION HAPPENS
		//
	}
}