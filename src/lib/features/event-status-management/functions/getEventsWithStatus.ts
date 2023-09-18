import type { Event, EventWithStatus } from '$lib/types/event/event.interface';
import { getVerifiersState } from '$lib/features/event-status-management/functions/helpers/getVerifiersState';
import { getEventGeneralStatus } from '$lib/features/event-status-management/functions/helpers/getEventGeneralStatus';

export const getEventsWithStatus = (events: Event[]): EventWithStatus[] => {
	const eventsWithStatus: EventWithStatus[] = [];

	for (const event of events) {
		const verifiersStatus = getVerifiersState(event.verifiers, Number(event.totalSupply));

		const eventWithStatus: EventWithStatus = {
			...event,
			status: {
				verifiersStatus: verifiersStatus,
				generalStatus: getEventGeneralStatus(verifiersStatus, event.claimable)
			}
		};

		eventsWithStatus.push(eventWithStatus);
	}

	return eventsWithStatus;
};
