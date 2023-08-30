import usersEventsMock from './_mock-data/usersEventsMock';
import type { EventWithStatus } from '$lib/types/event/event.interface';
import { getVerifiersState } from '$lib/features/event-status-management/functions/getVerifiersState';
import { getEventGeneralStatus } from '$lib/features/event-status-management/functions/getEventGeneralStatus';

export async function load() {
	const getEventsWithStatus = async (address: string): Promise<EventWithStatus[]> => {
		const userEvents = usersEventsMock;
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

	return {
		events: await getEventsWithStatus('hola')
	};
}
