import { getEvent, getLatestEventClaims } from '$flow/actions';
import { getFindProfileFromAddressOrName } from '$flow/utils';
import { getEventGeneralStatus } from '$lib/features/event-status-management/functions/helpers/getEventGeneralStatus.js';
import { getVerifiersState } from '$lib/features/event-status-management/functions/helpers/getVerifiersState.js';
import type { Event, EventWithStatus } from '$lib/types/event/event.interface.js';

export async function load({ params, depends }) {
	depends('app:event');

	const findProfile = await getFindProfileFromAddressOrName(params.username);

	let walletAddress = params.username;

	if (findProfile) {
		walletAddress = findProfile.address;
	}

	const event = await getEvent(walletAddress, params.eventId);

	const getEventWithStatus = (event: Event): EventWithStatus => {
		const verifiersStatus = getVerifiersState(event.verifiers, Number(event.totalSupply));

		const eventWithStatus: EventWithStatus = {
			...event,
			status: {
				verifiersStatus: verifiersStatus,
				generalStatus: getEventGeneralStatus(verifiersStatus)
			}
		};

		return eventWithStatus;
	};

	return {
		event: getEventWithStatus(event),
		claims: await getLatestEventClaims(walletAddress, params.eventId, 20)
	};
}
