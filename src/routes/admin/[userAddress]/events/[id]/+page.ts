import { getEvent, getEventClaims, getLatestEventClaims } from '$flow/actions';
import { getVerifiersState } from '$lib/features/event-status-management/functions/getVerifiersState';
import { getEventGeneralStatus } from '$lib/features/event-status-management/functions/getEventGeneralStatus';
import type { Event, EventWithStatus } from '$lib/types/event/event.interface';

export async function load({ params }) {
	const event = await getEvent(params.userAddress, params.id);
	const eventClaims = await getLatestEventClaims(params.userAddress, params.id, 20);

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
		eventClaims
	};
}
