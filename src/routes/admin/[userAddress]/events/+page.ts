import { getEvents } from '$flow/actions.js';
import { getEventGeneralStatus } from '$lib/features/event-status-management/functions/getEventGeneralStatus';
import { getVerifiersState } from '$lib/features/event-status-management/functions/getVerifiersState';
import type { Event, EventWithStatus } from '$lib/types/event/event.interface';

export async function load({ params }) {
	const response = await getEvents(params.userAddress);

	const userEvents = response.sort((a, b) => {
		const dateA = parseFloat(a.dateCreated);
		const dateB = parseFloat(b.dateCreated);
		return dateB - dateA;
	});

	const getEventsWithStatus = (events: Event[]): EventWithStatus[] => {
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

	return {
		events: getEventsWithStatus(userEvents)
	};
}
