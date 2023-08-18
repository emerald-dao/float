import { getEvent, getEventClaims } from '$flow/actions';
import { getFindProfileFromAddressOrName } from '$flow/utils';
import { getEventGeneralStatus } from '$lib/features/event-status-management/functions/getEventGeneralStatus.js';
import { getVerifiersState } from '$lib/features/event-status-management/functions/getVerifiersState.js';
import type { Event, EventWithStatus } from '$lib/types/event/event.interface.js';

export const load = async ({ params }) => {
	const findProfile = await getFindProfileFromAddressOrName(params.username);

	let walletAddress = params.username;

	if (findProfile) {
		walletAddress = findProfile.address;
	}

	const event = await getEvent(walletAddress, params.eventId);

	const getLatestClaims = async (address: string, eventId: string) => {
		const eventClaims = await getEventClaims(address, eventId);
		const latestClaims = Object.values(eventClaims)
			.sort((a, b) => Number(b.serial) - Number(a.serial))
			.slice(0, 20);

		return latestClaims;
	};

	const getEventWithStatus = (event: Event): EventWithStatus => {
		const verifiersStatus = getVerifiersState(event.verifiers, Number(event.totalSupply));

		const eventWithStatus: EventWithStatus = {
			...event,
			status: {
				verifiersStatus: verifiersStatus,
				generalStatus: getEventGeneralStatus(verifiersStatus, event.claimable)
			}
		};

		return eventWithStatus;
	};

	return {
		event: getEventWithStatus(event),
		claims: await getLatestClaims(walletAddress, params.eventId)
	};
};
