import {
	user
} from './stores.js';

import { get } from 'svelte/store'
import { resolver } from '$lib/stores.js';
import { SHA3 } from "sha3";
import { ec } from "elliptic";
import scrypt from "scrypt-async";
import { secretSalt } from "./config";

import { Buffer } from 'buffer';

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

export function parseErrorMessageFromFCL(errorString) {
	if (errorString.includes('bytes of storage which is over its capacity')) {
		const address = errorString.substring(errorString.indexOf('(') + 1, errorString.indexOf('(') + 17);
		return 'The account with address ' + address + ' needs more FLOW token in their account (.1 FLOW will be enough).';
	}
	if (errorString.includes('HTTP Request Error')) {
		return 'Flow Mainnet is currently undergoing maintenance. You can try to refresh the page or try again later.';
	}
	if (errorString.includes('sequence number')) {
		return 'Please refresh the page and try again.';
	}
	let newString = errorString.replace('[Error Code: 1101] cadence runtime error Execution failed:\nerror: assertion failed:', 'Error:')
	newString = newString.replace('[Error Code: 1101] cadence runtime error Execution failed:\nerror: panic:', 'Error:')
	newString = newString.replace('[Error Code: 1101] cadence runtime error Execution failed:\nerror: pre-condition failed:', 'Error:')
	newString = newString.replace('[Error Code: 1101] cadence runtime error Execution failed:\nerror: ', 'Error:')
	newString = newString.replace(/-->.*/, '');
	return newString;
}

export function getResolvedName(addressObject, priority = get(resolver)) {
	if (addressObject.resolvedNames[priority]) {
		return addressObject.resolvedNames[priority];
	}
	if (addressObject.resolvedNames['fn']) {
		return addressObject.resolvedNames['fn'];
	}
	if (addressObject.resolvedNames['find']) {
		return addressObject.resolvedNames['find'];
	}
	return addressObject.address;
}

export const formatter = new Intl.DateTimeFormat("en-US");

export function getKeysFromClaimCode(claimCode) {
	let keys;
	scrypt(
		claimCode, //password
		secretSalt, //use some salt for extra security
		{
			N: 16384, // iterations
			r: 8, // block size
			p: 1, // parallelism
			dkLen: 32, // 256-bit key
			encoding: "hex",
		},
		function (privateKey) {
			var ec_p256 = new ec("p256");
			let kp = ec_p256.keyFromPrivate(privateKey, "hex"); // hex string, array or Buffer
			var publicKey = kp.getPublic().encode("hex").substr(2);
			keys = { publicKey, privateKey };
		}
	);
	return keys;
}

const rightPaddedHexBuffer = (value, pad) => {
	return Buffer.from(value.padEnd(pad * 2, 0), "hex");
};

const USER_DOMAIN_TAG = rightPaddedHexBuffer(
	Buffer.from("FLOW-V0.0-user").toString("hex"),
	32
).toString("hex");

const sign = (message, privateKey) => {
	var ec_p256 = new ec("p256");
	const key = ec_p256.keyFromPrivate(Buffer.from(privateKey, "hex"));
	const sig = key.sign(hash(message)); // hashMsgHex -> hash
	const n = 32;
	const r = sig.r.toArrayLike(Buffer, "be", n);
	const s = sig.s.toArrayLike(Buffer, "be", n);
	return Buffer.concat([r, s]).toString("hex");
};

const hash = (message) => {
	const sha = new SHA3(256);
	sha.update(Buffer.from(message, "hex"));
	return sha.digest();
};

export function signWithClaimCode(claimCode) {
	if (!claimCode) {
		return null;
	}

	const { privateKey } = getKeysFromClaimCode(claimCode);
	// let messageToSign = '0x' + get(user).addr.substring(2).replace(/^0+/, '');
	const data = Buffer.from(get(user).addr).toString("hex");
	const sig = sign(USER_DOMAIN_TAG + data, privateKey);
	return sig;
}