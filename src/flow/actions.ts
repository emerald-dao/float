import { browser } from '$app/environment';
import * as fcl from '@onflow/fcl';
import './config';
import { user } from '$stores/flow/FlowStore';
import { executeTransaction, replaceWithProperValues } from './utils';
import type { Event } from '$lib/types/event/event.interface';

// Transactions
import createEventTx from './cadence/transactions/create_event.cdc?raw';

// Scripts
import getEventsScript from './cadence/scripts/get_events.cdc?raw';
import getEventScript from './cadence/scripts/get_event.cdc?raw';
import getFLOATsScript from './cadence/scripts/get_floats.cdc?raw';

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

const createEvent = async (floatObject) => {
	return await fcl.mutate({
		cadence: replaceWithProperValues(createEventTx),
		args: (arg, t) => [
			arg(floatObject.claimable, t.Bool),
			arg(floatObject.name, t.String),
			arg(floatObject.description, t.String),
			arg(floatObject.image, t.String),
			arg(floatObject.url, t.String),
			arg(floatObject.transferrable, t.Bool),
			arg(floatObject.timelock, t.Bool),
			arg(floatObject.dateStart.toFixed(1), t.UFix64),
			arg(floatObject.timePeriod.toFixed(1), t.UFix64),
			arg(floatObject.secret, t.Bool),
			arg(floatObject.secretPK, t.String),
			arg(floatObject.limited, t.Bool),
			arg(floatObject.capacity, t.UInt64),
			arg(floatObject.initialGroups, t.Array(t.String)),
			arg(floatObject.flowTokenPurchase, t.Bool),
			arg(floatObject.flowTokenCost, t.UFix64),
			arg(floatObject.minimumBalanceToggle, t.Bool),
			arg(floatObject.minimumBalance, t.UFix64),
			arg(floatObject.challengeCertificate, t.Bool),
			arg(floatObject.challengeHost, t.Optional(t.Address)),
			arg(floatObject.challengeId, t.Optional(t.UInt64)),
			arg(floatObject.challengeAchievementThreshold, t.Optional(t.UInt64))
		],
		proposer: fcl.authz,
		payer: fcl.authz,
		authorizations: [fcl.authz],
		limit: 9999
	});
};

export const createEventExecution = (floatObject) =>
	executeTransaction(() => createEvent(floatObject));

export const getEvents = async (userAddress: string): Promise<Event[]> => {
	try {
		return await fcl.query({
			cadence: replaceWithProperValues(getEventsScript),
			args: (arg, t) => [arg(userAddress, t.Address)]
		});
	} catch (e) {
		console.log('Error in getEvents', e);
		throw new Error('Error in getEvents');
	}
};

export const getEvent = async (eventHost: string, eventId: string) => {
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

export const getFLOATs = async (userAddress: string) => {
	try {
		return await fcl.query({
			cadence: replaceWithProperValues(getFLOATsScript),
			args: (arg, t) => [arg(userAddress, t.Address)]
		});
	} catch (e) {
		console.log('Error in getFLOATs', e);
		throw new Error('Error in getFLOATs');
	}
};
