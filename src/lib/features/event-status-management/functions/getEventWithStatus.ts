import { getVerifiersState } from '$lib/features/event-status-management/functions/helpers/getVerifiersState';
import { getEventGeneralStatus } from '$lib/features/event-status-management/functions/helpers/getEventGeneralStatus';
import type { Event, EventWithStatus } from '$lib/types/event/event.interface';

export const getEventWithStatus = (event: Event): EventWithStatus => {
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
