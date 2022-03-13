import FLOAT from "../FLOAT.cdc"
import NonFungibleToken from "../../core-contracts/NonFungibleToken.cdc"
import MetadataViews from "../../core-contracts/MetadataViews.cdc"
import SharedAccount from "../../sharedaccount/SharedAccount.cdc"

transaction(forHost: Address, eventId: UInt64, recipients: [Address]) {

	let FLOATEvents: &FLOAT.FLOATEvents
	let FLOATEvent: &FLOAT.FLOATEvent
	let RecipientCollections: [&FLOAT.Collection{NonFungibleToken.CollectionPublic}]

	prepare(acct: AuthAccount) {
		// SETUP COLLECTION
    if acct.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath) == nil {
        acct.save(<- FLOAT.createEmptyCollection(), to: FLOAT.FLOATCollectionStoragePath)
        acct.link<&FLOAT.Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, FLOAT.CollectionPublic}>
                (FLOAT.FLOATCollectionPublicPath, target: FLOAT.FLOATCollectionStoragePath)
    }

    // SETUP FLOATEVENTS
    if acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath) == nil {
      acct.save(<- FLOAT.createEmptyFLOATEventCollection(), to: FLOAT.FLOATEventsStoragePath)
      acct.link<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, MetadataViews.ResolverCollection}>
                (FLOAT.FLOATEventsPublicPath, target: FLOAT.FLOATEventsStoragePath)
    }

    // SETUP SHARED MINTING
    if acct.borrow<&SharedAccount.Info>(from: SharedAccount.InfoStoragePath) == nil {
        acct.save(<- SharedAccount.createInfo(), to: SharedAccount.InfoStoragePath)
        acct.link<&SharedAccount.Info{SharedAccount.InfoPublic}>
                (SharedAccount.InfoPublicPath, target: SharedAccount.InfoStoragePath)
    }

		if forHost != acct.address {
      let FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                        ?? panic("Could not borrow the FLOATEvents from the signer.")
      self.FLOATEvents = FLOATEvents.borrowSharedRef(fromHost: forHost)
    } else {
      self.FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                        ?? panic("Could not borrow the FLOATEvents from the signer.")
    }

		self.FLOATEvent = self.FLOATEvents.borrowEventRef(eventId: eventId) ?? panic("This event does not exist.")
		self.RecipientCollections = []
    for recipient in recipients {
      if let recipientCollection = getAccount(recipient).getCapability(FLOAT.FLOATCollectionPublicPath).borrow<&FLOAT.Collection{NonFungibleToken.CollectionPublic}>() {
        self.RecipientCollections.append(recipientCollection)
      }
    }
	}

	execute {
		//
		// Give the "recipients" a FLOAT from the event with "id"
		//

		self.FLOATEvent.batchMint(recipients: self.RecipientCollections)
		log("Distributed the FLOAT.")
	}
}