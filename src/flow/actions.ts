import { browser } from '$app/environment';
import * as fcl from '@onflow/fcl';
import './config';
import { addresses, user } from '$stores/flow/FlowStore';
import { executeTransaction, replaceWithProperValues } from './utils';
import type { Event } from '$lib/types/event/event.interface';

// Transactions
import createEventTx from './cadence/transactions/create_event.cdc?raw';
import burnFLOATTx from './cadence/transactions/burn_float.cdc?raw';
import claimFLOATTx from './cadence/transactions/claim.cdc?raw';
import deleteEventTx from './cadence/transactions/delete_event.cdc?raw';
import toggleClaimingTx from './cadence/transactions/toggle_claimable.cdc?raw';
import toggleTransferringTx from './cadence/transactions/toggle_transferrable.cdc?raw';

// Scripts
import getEventsScript from './cadence/scripts/get_events.cdc?raw';
import getEventScript from './cadence/scripts/get_event.cdc?raw';
import getFLOATsScript from './cadence/scripts/get_floats.cdc?raw';
import getSpecificFLOATsScript from './cadence/scripts/get_specific_floats.cdc?raw';
import getEventClaimsScript from './cadence/scripts/get_claimed_in_event.cdc?raw';
import getLatestEventClaimsScript from './cadence/scripts/get_latest_claimed_in_event.cdc?raw';
import getStatsScript from './cadence/scripts/get_stats.cdc?raw';
import getMainPageFLOATsScript from './cadence/scripts/get_main_page_floats.cdc?raw';
import validateSecretCodeForClaimScript from './cadence/scripts/validate_secret_code.cdc?raw';

import type { Claim } from '$lib/types/event/event-claim.interface';
import type { FLOAT } from '$lib/types/float/float.interface';
import type { EventType } from '$lib/types/event/even-type.type';
import type { Limited, Secret, Timelock } from '$lib/types/event/verifiers.interface';
import { signWithClaimCode } from './sign';

if (browser) {
	// set Svelte $user store to currentUser,
	// so other components can access it
	fcl.currentUser.subscribe(user.set, []);
}

// Lifecycle FCL Auth functions
export const unauthenticate = () => fcl.unauthenticate();
export const logIn = async () => fcl.logIn();
export const signUp = () => fcl.signUp();

/****************************** SETTERS ******************************/

const createEvent = async (
	name: string,
	description: string,
	url: string,
	logo: string,
	backImage: string,
	transferrable: boolean,
	claimable: boolean,
	eventType: EventType,
	timelock: Timelock | null,
	secret: string | null,
	limited: number | null,
	payment: number | null,
	minimumBalance: number | null
) => {
	const startDate = timelock != null ? Number(timelock.dateStart) : 0;
	const timePeriod =
		timelock != null ? Number(timelock.dateEnding) - Number(timelock.dateStart) : 0;

	return await fcl.mutate({
		cadence: replaceWithProperValues(createEventTx),
		args: (arg, t) => [
			arg(name, t.String),
			arg(description, t.String),
			arg(url, t.String),
			arg(logo, t.String),
			arg(backImage, t.String),
			arg(transferrable, t.Bool),
			arg(claimable, t.Bool),
			arg(eventType, t.String),
			arg(timelock != null, t.Bool),
			arg(startDate.toFixed(1), t.UFix64),
			arg(timePeriod.toFixed(1), t.UFix64),
			arg(secret != null, t.Bool),
			arg(secret != null ? secret : '', t.String),
			arg(limited != null, t.Bool),
			arg(limited != null ? limited : '0', t.UInt64),
			arg(payment != null, t.Bool),
			arg(payment != null ? payment.toFixed(1) : '0.0', t.UFix64),
			arg(minimumBalance != null, t.Bool),
			arg(minimumBalance != null ? minimumBalance.toFixed(1) : '0.0', t.UFix64)
		],
		proposer: fcl.authz,
		payer: fcl.authz,
		authorizations: [fcl.authz],
		limit: 9999
	});
};

export const createEventExecution = (
	name: string,
	description: string,
	url: string,
	logo: string,
	backImage: string,
	transferrable: boolean,
	claimable: boolean,
	eventType: EventType,
	timelock: Timelock | null,
	secret: string | null,
	limited: number | null,
	payment: number | null,
	minimumBalance: number | null
) =>
	executeTransaction(() =>
		createEvent(
			name,
			description,
			url,
			logo,
			backImage,
			transferrable,
			claimable,
			eventType,
			timelock,
			secret,
			limited,
			payment,
			minimumBalance
		)
	);

const burnFLOAT = async (floatId: string) => {
	return await fcl.mutate({
		cadence: replaceWithProperValues(burnFLOATTx),
		args: (arg, t) => [arg(floatId, t.UInt64)],
		proposer: fcl.authz,
		payer: fcl.authz,
		authorizations: [fcl.authz],
		limit: 9999
	});
};

export const burnFLOATExecution = (floatId: string) => executeTransaction(() => burnFLOAT(floatId));

const claimFLOAT = async (eventId: string, eventCreator: string) => {
	return await fcl.mutate({
		cadence: replaceWithProperValues(claimFLOATTx),
		args: (arg, t) => [
			arg(eventId, t.UInt64),
			arg(eventCreator, t.Address),
			arg(null, t.Optional(t.String))
		],
		proposer: fcl.authz,
		payer: fcl.authz,
		authorizations: [fcl.authz],
		limit: 9999
	});
};

export const claimFLOATExecution = (eventId: string, eventCreator: string) =>
	executeTransaction(() => claimFLOAT(eventId, eventCreator));

const deleteEvent = async (eventId: string) => {
	return await fcl.mutate({
		cadence: replaceWithProperValues(deleteEventTx),
		args: (arg, t) => [arg(eventId, t.UInt64)],
		proposer: fcl.authz,
		payer: fcl.authz,
		authorizations: [fcl.authz],
		limit: 9999
	});
};

export const deleteEventExecution = (eventId: string) =>
	executeTransaction(() => deleteEvent(eventId));

const toggleClaiming = async (eventId: string) => {
	return await fcl.mutate({
		cadence: replaceWithProperValues(toggleClaimingTx),
		args: (arg, t) => [arg(eventId, t.UInt64)],
		proposer: fcl.authz,
		payer: fcl.authz,
		authorizations: [fcl.authz],
		limit: 9999
	});
};

export const toggleClaimingExecution = (eventId: string) =>
	executeTransaction(() => toggleClaiming(eventId));

const toggleTransferring = async (eventId: string) => {
	return await fcl.mutate({
		cadence: replaceWithProperValues(toggleTransferringTx),
		args: (arg, t) => [arg(eventId, t.UInt64)],
		proposer: fcl.authz,
		payer: fcl.authz,
		authorizations: [fcl.authz],
		limit: 9999
	});
};

export const toggleTransferringExecution = (eventId: string) =>
	executeTransaction(() => toggleTransferring(eventId));

// Scripts

export const getEvents = async (userAddress: string): Promise<Event[]> => {
	try {
		return await fcl.query({
			cadence: replaceWithProperValues(getEventsScript),
			args: (arg, t) => [arg(userAddress, t.Address)]
		});
	} catch (e) {
		console.log('Error in getEvents', e);
		return [];
	}
};

export const getEvent = async (eventHost: string, eventId: string): Promise<Event> => {
	try {
		return await fcl.query({
			cadence: replaceWithProperValues(getEventScript),
			args: (arg, t) => [arg(eventHost, t.Address), arg(eventId, t.UInt64)]
		});
	} catch (e) {
		console.log('Error in getEvents', e);
		throw new Error('Error in getEvents');
	}
};

export const getEventClaims = async (eventHost: string, eventId: string): Promise<Claim[]> => {
	try {
		return await fcl.query({
			cadence: replaceWithProperValues(getEventClaimsScript),
			args: (arg, t) => [arg(eventHost, t.Address), arg(eventId, t.UInt64)]
		});
	} catch (e) {
		console.log('Error in getEventClaims', e);
		throw new Error('Error in getEventClaims');
	}
};

export const getLatestEventClaims = async (eventHost: string, eventId: string, amount: number): Promise<Claim[]> => {
	try {
		const result = await fcl.query({
			cadence: replaceWithProperValues(getLatestEventClaimsScript),
			args: (arg, t) => [arg(eventHost, t.Address), arg(eventId, t.UInt64), arg(amount.toString(), t.UInt64)]
		});
		return result.sort((a, b) => Number(b.serial) - Number(a.serial))
	} catch (e) {
		console.log('Error in getLatestEventClaims', e);
		throw new Error('Error in getLatestEventClaims');
	}
};

export const getFLOATs = async (userAddress: string): Promise<FLOAT[]> => {
	try {
		return await fcl.query({
			cadence: replaceWithProperValues(getFLOATsScript),
			args: (arg, t) => [arg(userAddress, t.Address)]
		});
	} catch (e) {
		console.log('Error in getFLOATs', e);
		return [];
	}
};

export const getSpecificFLOATs = async (userAddress: string, ids: string[]) => {
	try {
		return await fcl.query({
			cadence: replaceWithProperValues(getSpecificFLOATsScript),
			args: (arg, t) => [arg(userAddress, t.Address), arg(ids, t.Array(t.UInt64))]
		});
	} catch (e) {
		console.log('Error in getSpecificFLOATs', e);
		throw new Error('Error in getSpecificFLOATs');
	}
};

export const getStats = async () => {
	try {
		return await fcl.query({
			cadence: replaceWithProperValues(getStatsScript),
			args: (arg, t) => []
		});
	} catch (e) {
		console.log(e);
		return {};
	}
};

export const getMainPageFLOATs = async (floats: { key: string; value: string[] }[]) => {
	try {
		return await fcl.query({
			cadence: replaceWithProperValues(getMainPageFLOATsScript),
			args: (arg, t) => [arg(floats, t.Dictionary({ key: t.Address, value: t.Array(t.UInt64) }))]
		});
	} catch (e) {
		console.log(e);
		return {};
	}
};

export const validateSecretCodeForClaim = async (eventId: string, eventHost: string, secretCode: string, claimeeAddress: string, secretSalt: string) => {
	try {
		const secretSig = signWithClaimCode(secretCode, secretSalt, claimeeAddress);
		let cadence = replaceWithProperValues(validateSecretCodeForClaimScript)
		cadence = cadence.replaceAll("${verifiersIdentifier}", `A.${addresses.FLOAT.substring(2)}`)
		return await fcl.query({
			cadence,
			args: (arg, t) => [
				arg(eventId, t.UInt64),
				arg(eventHost, t.Address),
				arg(secretSig, t.String),
				arg(claimeeAddress, t.Address)
			]
		});
	} catch (e) {
		console.log(e);
		return false;
	}
};