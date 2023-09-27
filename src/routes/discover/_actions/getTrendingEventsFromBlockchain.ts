import { getEventsBatch } from '$flow/actions';
import { getEventGeneralStatus } from '$lib/features/event-status-management/functions/helpers/getEventGeneralStatus';
import { getVerifiersState } from '$lib/features/event-status-management/functions/helpers/getVerifiersState';
import type { Event, EventWithStatus } from '$lib/types/event/event.interface';

const getTrendingEventsFromBlockchain = async (
	events: {
		user_address: string;
		event_id: string;
	}[]
) => {
	try {
		let blockchainEvents = await getEventsBatch(events);

		let trendingEvents = await getEventsWithStatus(blockchainEvents);

		return trendingEvents;
	} catch (error) {
		console.error('Error fetching events from the blockchain:', error);

		return [];
	}
};

export default getTrendingEventsFromBlockchain;

const getEventsWithStatus = async (events: Event[]): Promise<EventWithStatus[]> => {
	const eventsWithStatus: EventWithStatus[] = [];

	for (const event of events) {
		const verifiersStatus = getVerifiersState(event.verifiers, Number(event.totalSupply));

		const eventWithStatus: EventWithStatus = {
			...event,
			status: {
				verifiersStatus: verifiersStatus,
				generalStatus: getEventGeneralStatus(verifiersStatus)
			}
		};

		eventsWithStatus.push(eventWithStatus);
	}

	return eventsWithStatus;
};
