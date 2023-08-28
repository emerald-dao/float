import FLOAT from "../FLOAT.cdc"
import NonFungibleToken from "../utility/NonFungibleToken.cdc"

transaction(eventId: UInt64, recipients: [Address]) {

	let FLOATEvents: &FLOAT.FLOATEvents
	let FLOATEvent: &FLOAT.FLOATEvent

	prepare(acct: AuthAccount) {
    self.FLOATEvents = acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                      ?? panic("Could not borrow the FLOATEvents from the signer.")
		self.FLOATEvent = self.FLOATEvents.borrowEventRef(eventId: eventId) ?? panic("This event does not exist.")
	}

	execute {
		for address in recipients {
			let recipientCollection = getAccount(address).getCapability(FLOAT.FLOATCollectionPublicPath)
																.borrow<&FLOAT.Collection{NonFungibleToken.CollectionPublic}>()
																?? panic("Could not get the public FLOAT Collection from the recipient.")
			self.FLOATEvent.mint(recipient: recipientCollection)
		}
	}
}