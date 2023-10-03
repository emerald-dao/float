import { browser } from '$app/environment';
import * as fcl from '@blocto/fcl';
import './config';
import { addresses, user } from '$stores/flow/FlowStore';
import { executeTransaction, replaceWithProperValues } from './utils';
import type { Event } from '$lib/types/event/event.interface';
import type { Claim } from '$lib/types/event/event-claim.interface';
import type { FLOAT } from '$lib/types/float/float.interface';
import type { CertificateType, EventType } from '$lib/types/event/event-type.type';
import type { Timelock } from '$lib/types/event/verifiers.interface';
import { signWithClaimCode } from './sign';
import { fetchKeysFromClaimCode } from '$lib/utilities/api/fetchKeysFromClaimCode';
import type { TransactionStatusObject } from '@blocto/fcl';
import type { ActionExecutionResult } from '$stores/custom/steps/step.interface';

// Transactions
import createEventTx from './cadence/transactions/create_event.cdc?raw';
import createMedalEventTx from './cadence/transactions/create_event_medal.cdc?raw';
import burnFLOATTx from './cadence/transactions/burn_float.cdc?raw';
import claimFLOATTx from './cadence/transactions/claim_float.cdc?raw';
import purchaseFLOATTx from './cadence/transactions/purchase_float.cdc?raw';
import deleteEventTx from './cadence/transactions/delete_event.cdc?raw';
import toggleClaimingTx from './cadence/transactions/toggle_claimable.cdc?raw';
import toggleTransferringTx from './cadence/transactions/toggle_transferrable.cdc?raw';
import toggleVisibilityModeTx from './cadence/transactions/toggle_visibility_mode.cdc?raw';
import distributeFLOATsTx from './cadence/transactions/distribute_floats.cdc?raw';
import distributeMedalFLOATsTx from './cadence/transactions/distribute_floats_medal.cdc?raw';

// Scripts
import getEventsScript from './cadence/scripts/get_events.cdc?raw';
import getEventScript from './cadence/scripts/get_event.cdc?raw';
import getEventsBatchScript from './cadence/scripts/get_events_batch.cdc?raw';
import getFLOATsScript from './cadence/scripts/get_floats.cdc?raw';
import getSpecificFLOATsScript from './cadence/scripts/get_specific_floats.cdc?raw';
import getLatestEventClaimsScript from './cadence/scripts/get_latest_claimed_in_event.cdc?raw';
import getStatsScript from './cadence/scripts/get_stats.cdc?raw';
import getMainPageFLOATsScript from './cadence/scripts/get_main_page_floats.cdc?raw';
import hasFLOATCollectionSetupScript from './cadence/scripts/has_float_collection_setup.cdc?raw';
import validateSecretCodeForClaimScript from './cadence/scripts/validate_secret_code.cdc?raw';
import userHasClaimedEventScript from './cadence/scripts/has_claimed_event.cdc?raw';
import userCanMintScript from './cadence/scripts/user_can_mint.cdc?raw';
import validateAddressExistanceScript from './cadence/scripts/validate_address_existance.cdc?raw';
import validateFindExistanceScript from './cadence/scripts/validate_find_existance.cdc?raw';

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
	certificateImage: string,
	transferrable: boolean,
	claimable: boolean,
	eventType: EventType,
	certificateType: CertificateType,
	timelock: Timelock | null,
	secret: string | null,
	limited: number | null,
	payment: number | null,
	minimumBalance: number | null,
	visibilityMode: 'certificate' | 'picture',
	multipleClaim: boolean,
	startDate: number,
	timePeriod: number,
	secretPK: string
) => {
	return await fcl.mutate({
		cadence: replaceWithProperValues(createEventTx),
		args: (arg, t) => [
			arg(name, t.String),
			arg(description, t.String),
			arg(url, t.String),
			arg(logo, t.String),
			arg(backImage, t.String),
			arg(certificateImage, t.String),
			arg(transferrable, t.Bool),
			arg(claimable, t.Bool),
			arg(eventType, t.String),
			arg(certificateType, t.String),
			arg(timelock != null, t.Bool),
			arg(startDate.toFixed(1), t.UFix64),
			arg(timePeriod.toFixed(1), t.UFix64),
			arg(secret != null, t.Bool),
			arg(secret != null ? secretPK : '', t.String),
			arg(limited != null, t.Bool),
			arg(limited != null ? limited : '0', t.UInt64),
			arg(payment != null, t.Bool),
			arg(payment != null ? payment.toFixed(1) : '0.0', t.UFix64),
			arg(minimumBalance != null, t.Bool),
			arg(minimumBalance != null ? minimumBalance.toFixed(1) : '0.0', t.UFix64),
			arg(visibilityMode, t.String),
			arg(multipleClaim, t.Bool)
		],
		proposer: fcl.authz,
		payer: fcl.authz,
		authorizations: [fcl.authz],
		limit: 9999
	});
};

const createMedalEvent = async (
	name: string,
	description: string,
	url: string,
	logo: string,
	backImage: string,
	certificateImage: { gold: string; silver: string; bronze: string; participation: string },
	transferrable: boolean,
	claimable: boolean,
	eventType: EventType,
	certificateType: CertificateType,
	timelock: Timelock | null,
	secret: string | null,
	limited: number | null,
	payment: number | null,
	minimumBalance: number | null,
	visibilityMode: 'certificate' | 'picture',
	multipleClaim: boolean,
	startDate: number,
	timePeriod: number,
	secretPK: string
) => {
	let certificateImagesArg = [
		{ key: 'gold', value: certificateImage['gold'] },
		{ key: 'silver', value: certificateImage['silver'] },
		{ key: 'bronze', value: certificateImage['bronze'] },
		{ key: 'participation', value: certificateImage['participation'] }
	];

	return await fcl.mutate({
		cadence: replaceWithProperValues(createMedalEventTx),
		args: (arg, t) => [
			arg(name, t.String),
			arg(description, t.String),
			arg(url, t.String),
			arg(logo, t.String),
			arg(backImage, t.String),
			arg(certificateImagesArg, t.Dictionary({ key: t.String, value: t.String })),
			arg(transferrable, t.Bool),
			arg(claimable, t.Bool),
			arg(eventType, t.String),
			arg(certificateType, t.String),
			arg(timelock != null, t.Bool),
			arg(startDate.toFixed(1), t.UFix64),
			arg(timePeriod.toFixed(1), t.UFix64),
			arg(secret != null, t.Bool),
			arg(secret != null ? secretPK : '', t.String),
			arg(limited != null, t.Bool),
			arg(limited != null ? limited : '0', t.UInt64),
			arg(payment != null, t.Bool),
			arg(payment != null ? payment.toFixed(1) : '0.0', t.UFix64),
			arg(minimumBalance != null, t.Bool),
			arg(minimumBalance != null ? minimumBalance.toFixed(1) : '0.0', t.UFix64),
			arg(visibilityMode, t.String),
			arg(multipleClaim, t.Bool)
		],
		proposer: fcl.authz,
		payer: fcl.authz,
		authorizations: [fcl.authz],
		limit: 9999
	});
};

export const createEventExecution = async (
	name: string,
	description: string,
	url: string,
	logo: string,
	backImage: string,
	certificateImage:
		| string
		| { gold: string; silver: string; bronze: string; participation: string },
	transferrable: boolean,
	claimable: boolean,
	eventType: EventType,
	certificateType: CertificateType,
	timelock: { dateStart: string; dateEnding: string } | null,
	secret: string | null,
	limited: number | null,
	payment: number | null,
	minimumBalance: number | null,
	visibilityMode: 'certificate' | 'picture',
	multipleClaim: boolean,
	actionAfterSucceed: (res: TransactionStatusObject) => Promise<ActionExecutionResult>
) => {
	const startDate = timelock != null ? Number(timelock.dateStart) : 0;
	const timePeriod =
		timelock != null ? Number(timelock.dateEnding) - Number(timelock.dateStart) : 0;

	let secretPK = '';
	if (secret) {
		const { publicKey } = await fetchKeysFromClaimCode(secret);
		secretPK = publicKey;
	}

	if (certificateType === 'medal') {
		return executeTransaction(
			() =>
				createMedalEvent(
					name,
					description,
					url,
					logo,
					backImage,
					certificateImage as {
						gold: string;
						silver: string;
						bronze: string;
						participation: string;
					},
					transferrable,
					claimable,
					eventType,
					certificateType,
					timelock,
					secret,
					limited,
					payment,
					minimumBalance,
					visibilityMode,
					multipleClaim,
					startDate,
					timePeriod,
					secretPK
				),
			actionAfterSucceed
		);
	}
	return executeTransaction(
		() =>
			createEvent(
				name,
				description,
				url,
				logo,
				backImage,
				certificateImage as string,
				transferrable,
				claimable,
				eventType,
				certificateType,
				timelock,
				secret,
				limited,
				payment,
				minimumBalance,
				visibilityMode,
				multipleClaim,
				startDate,
				timePeriod,
				secretPK
			),
		actionAfterSucceed
	);
};

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

const claimFLOAT = async (eventId: string, eventCreator: string, secretSig: string | null) => {
	return await fcl.mutate({
		cadence: replaceWithProperValues(claimFLOATTx),
		args: (arg, t) => [
			arg(eventId, t.UInt64),
			arg(eventCreator, t.Address),
			arg(secretSig, t.Optional(t.String))
		],
		proposer: fcl.authz,
		payer: fcl.authz,
		authorizations: [fcl.authz],
		limit: 9999
	});
};

const purchaseFLOAT = async (eventId: string, eventCreator: string, secretSig: string | null) => {
	return await fcl.mutate({
		cadence: replaceWithProperValues(purchaseFLOATTx),
		args: (arg, t) => [
			arg(eventId, t.UInt64),
			arg(eventCreator, t.Address),
			arg(secretSig, t.Optional(t.String))
		],
		proposer: fcl.authz,
		payer: fcl.authz,
		authorizations: [fcl.authz],
		limit: 9999
	});
};

export const claimFLOATExecution = (
	eventId: string,
	eventCreator: string,
	secretSig: string | null,
	free: boolean,
	actionAfterSucceed: (res: TransactionStatusObject) => Promise<ActionExecutionResult>
) => {
	if (free) {
		return executeTransaction(
			() => claimFLOAT(eventId, eventCreator, secretSig),
			actionAfterSucceed
		);
	}
	return executeTransaction(
		() => purchaseFLOAT(eventId, eventCreator, secretSig),
		actionAfterSucceed
	);
};

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

const toggleVisibilityMode = async (eventId: string) => {
	return await fcl.mutate({
		cadence: replaceWithProperValues(toggleVisibilityModeTx),
		args: (arg, t) => [arg(eventId, t.UInt64)],
		proposer: fcl.authz,
		payer: fcl.authz,
		authorizations: [fcl.authz],
		limit: 9999
	});
};

export const toggleVisibilityModeExecution = (eventId: string) =>
	executeTransaction(() => toggleVisibilityMode(eventId));

const distributeFLOATs = async (eventId: string, addresses: string[]) => {
	return await fcl.mutate({
		cadence: replaceWithProperValues(distributeFLOATsTx),
		args: (arg, t) => [arg(eventId, t.UInt64), arg(addresses, t.Array(t.Address))],
		proposer: fcl.authz,
		payer: fcl.authz,
		authorizations: [fcl.authz],
		limit: 9999
	});
};

export const distributeFLOATsExecution = (eventId: string, addresses: string[]) =>
	executeTransaction(() => distributeFLOATs(eventId, addresses));

const distributeMedalFLOATs = async (
	eventId: string,
	addresses: string[],
	medalTypes: { address: string; medal: string }[]
) => {
	let medalTypesArg = medalTypes.map((obj) => {
		return { key: obj.address, value: obj.medal };
	});

	return await fcl.mutate({
		cadence: replaceWithProperValues(distributeMedalFLOATsTx),
		args: (arg, t) => [
			arg(eventId, t.UInt64),
			arg(addresses, t.Array(t.Address)),
			arg(medalTypesArg, t.Dictionary({ key: t.Address, value: t.String }))
		],
		proposer: fcl.authz,
		payer: fcl.authz,
		authorizations: [fcl.authz],
		limit: 9999
	});
};

export const distributeMedalFLOATsExecution = (
	eventId: string,
	addresses: string[],
	medalTypes: { address: string; medal: string }[]
) => executeTransaction(() => distributeMedalFLOATs(eventId, addresses, medalTypes));

// Scripts

export const getEvents = async (userAddress: string): Promise<Event[]> => {
	try {
		let events = await fcl.query({
			cadence: replaceWithProperValues(getEventsScript),
			args: (arg, t) => [arg(userAddress, t.Address)]
		});
		let sortedEvents = events.sort((a: Event, b: Event) => {
			const dateA = parseFloat(a.dateCreated);
			const dateB = parseFloat(b.dateCreated);
			return dateB - dateA;
		});
		return sortedEvents;
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
		console.log('Error in getEvent', e);
		throw new Error('Error in getEvent');
	}
};

export const getEventsBatch = async (
	events: { creator_address: string; id: string }[]
): Promise<Event[]> => {
	try {
		let eventsArg = [];
		let addressesArg = [];
		events.forEach((event) => {
			eventsArg.push(event.id);
			addressesArg.push(event.creator_address);
		});
		return await fcl.query({
			cadence: replaceWithProperValues(getEventsBatchScript),
			args: (arg, t) => [arg(eventsArg, t.Array(t.UInt64)), arg(addressesArg, t.Array(t.Address))]
		});
	} catch (e) {
		console.log('Error in getEventsBatch', e);
		throw new Error('Error in getEventsBatch');
	}
};

export const getLatestEventClaims = async (
	eventHost: string,
	eventId: string,
	amount: number
): Promise<Claim[]> => {
	try {
		const result = await fcl.query({
			cadence: replaceWithProperValues(getLatestEventClaimsScript),
			args: (arg, t) => [
				arg(eventHost, t.Address),
				arg(eventId, t.UInt64),
				arg(amount.toString(), t.UInt64)
			]
		});
		return result.sort((a, b) => Number(b.serial) - Number(a.serial));
	} catch (e) {
		console.log('Error in getLatestEventClaims', e);
		throw new Error('Error in getLatestEventClaims');
	}
};

export const getFLOATs = async (userAddress: string): Promise<FLOAT[]> => {
	try {
		let floats = await fcl.query({
			cadence: replaceWithProperValues(getFLOATsScript),
			args: (arg, t) => [arg(userAddress, t.Address)]
		});
		let sortedFloats = floats.sort((a: FLOAT, b: FLOAT) => {
			const dateA = parseFloat(a.dateReceived);
			const dateB = parseFloat(b.dateReceived);
			return dateB - dateA;
		});
		return sortedFloats;
	} catch (e) {
		console.log('Error in getFLOATs', e);
		return [];
	}
};

export const getSpecificFLOATs = async (userAddress: string, ids: string[]): Promise<FLOAT[]> => {
	try {
		let floats = await fcl.query({
			cadence: replaceWithProperValues(getSpecificFLOATsScript),
			args: (arg, t) => [arg(userAddress, t.Address), arg(ids, t.Array(t.UInt64))]
		});
		let sortedFloats = floats.sort((a: FLOAT, b: FLOAT) => {
			const dateA = parseFloat(a.dateReceived);
			const dateB = parseFloat(b.dateReceived);
			return dateB - dateA;
		});
		return sortedFloats;
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

export const hasFLOATCollectionSetUp = async (address: string) => {
	try {
		return (await fcl.query({
			cadence: replaceWithProperValues(hasFLOATCollectionSetupScript),
			args: (arg, t) => [arg(address, t.Address)]
		})) as boolean;
	} catch (e) {
		console.log(e);
		return false;
	}
};

export const validateSecretCodeForClaim = async (
	eventId: string,
	eventHost: string,
	secretCode: string,
	claimeeAddress: string
) => {
	try {
		const secretSig = await signWithClaimCode(secretCode, claimeeAddress);
		let cadence = replaceWithProperValues(validateSecretCodeForClaimScript);
		cadence = cadence.replaceAll('${verifiersIdentifier}', `A.${addresses.FLOAT.substring(2)}`);
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

export const userHasClaimedEvent = async (
	eventId: string,
	eventHost: string,
	userAddress: string
) => {
	try {
		return await fcl.query({
			cadence: replaceWithProperValues(userHasClaimedEventScript),
			args: (arg, t) => [
				arg(eventId, t.UInt64),
				arg(eventHost, t.Address),
				arg(userAddress, t.Address)
			]
		});
	} catch (e) {
		console.log(e);
		return false;
	}
};

export const userCanMint = async (eventId: string, eventHost: string, userAddress: string) => {
	try {
		return await fcl.query({
			cadence: replaceWithProperValues(userCanMintScript),
			args: (arg, t) => [
				arg(eventId, t.UInt64),
				arg(eventHost, t.Address),
				arg(userAddress, t.Address)
			]
		});
	} catch (e) {
		console.log(e);
		return false;
	}
};

export const validateAddressExistance = async (address: string) => {
	try {
		return await fcl.query({
			cadence: replaceWithProperValues(validateAddressExistanceScript),
			args: (arg, t) => [arg(address, t.Address)]
		});
	} catch (e) {
		console.log(e);
		return false;
	}
};

export const validateFindExistance = async (findName: string) => {
	try {
		return await fcl.query({
			cadence: replaceWithProperValues(validateFindExistanceScript),
			args: (arg, t) => [arg(findName, t.String)]
		});
	} catch (e) {
		console.log(e);
		return false;
	}
};
