import "FLOAT"
import "NonFungibleToken"

transaction(eventId: UInt64, recipients: [Address]) {

	let FLOATEvent: auth(FLOAT.EventOwner) &FLOAT.FLOATEvent

	prepare(account: auth(Storage) &Account) {
    	let FLOATEvents = account.storage.borrow<auth(FLOAT.EventsOwner) &FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                      ?? panic("Could not borrow the FLOATEvents from the signer.")
		self.FLOATEvent = FLOATEvents.borrowEventRef(eventId: eventId) ?? panic("This event does not exist.")
	}

	execute {
		for i, address in recipients {
			let recipientCollection: &FLOAT.Collection = getAccount(address).capabilities.borrow<&FLOAT.Collection>(FLOAT.FLOATCollectionPublicPath)
																?? panic("Could not get the public FLOAT Collection from the recipient.")
			self.FLOATEvent.mint(recipient: recipientCollection, optExtraFloatMetadata: nil)
		}
	}
}