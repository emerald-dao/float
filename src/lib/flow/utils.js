import {
  user
} from './stores.js';

import { get } from 'svelte/store'
import { resolver } from '$lib/stores.js';

export function parseErrorMessageFromFCL(errorString) {
  let newString = errorString?.replace('[Error Code: 1101] cadence runtime error Execution failed:\nerror: assertion failed:', 'Error:')
	newString = newString.replace('[Error Code: 1101] cadence runtime error Execution failed:\nerror: panic:', 'Error:')
  newString = newString.replace('[Error Code: 1101] cadence runtime error Execution failed:\nerror: pre-condition failed:', 'Error')
	newString = newString.replace(/-->.*/,'');
  return newString;
}

export let distributeCode = `
import FLOAT from 0xFLOAT
import NonFungibleToken from 0xCORE
import MetadataViews from 0xCORE

transaction(eventId: UInt64, recipient: Address) {

	let FLOATEvent: &FLOAT.FLOATEvent
	let RecipientCollection: &FLOAT.Collection{NonFungibleToken.CollectionPublic}

	prepare(signer: AuthAccount) {

    let FLOATEvents = signer.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath)
                      ?? panic("Could not borrow the FLOATEvents from the signer.")

		self.FLOATEvent = FLOATEvents.borrowEventRef(eventId: eventId)
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
`;

export function getResolvedName(addressObject, priority = get(resolver)) {
	if (addressObject.resolvedNames[priority]) {
		return addressObject.resolvedNames[priority];
	}
	return addressObject.address;
}