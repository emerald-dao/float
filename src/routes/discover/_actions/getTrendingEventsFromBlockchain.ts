import { getEventsBatch } from '$flow/actions';
import { getEventGeneralStatus } from '$lib/features/event-status-management/functions/helpers/getEventGeneralStatus';
import { getVerifiersState } from '$lib/features/event-status-management/functions/helpers/getVerifiersState';
import type { EventWithStatus } from '$lib/types/event/event.interface';
import { getTrendingEvents } from '../_api/getTrendingEvents';

const getTrendingEventsFromBlockchain = async () => {
	let response = await getTrendingEvents();

	let events = await getEventsBatch(response.eventsData);

	const getEventsWithStatus = async (): Promise<EventWithStatus[]> => {
		const userEvents = events;
		const eventsWithStatus: EventWithStatus[] = [];

		for (const event of userEvents) {
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

	let trendingEvents = await getEventsWithStatus();

	return trendingEvents;
};

export default getTrendingEventsFromBlockchain;
