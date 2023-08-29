import { getEvents, getFLOATs } from '$flow/actions.js';
import { getEventGeneralStatus } from '$lib/features/event-status-management/functions/getEventGeneralStatus.js';
import { getVerifiersState } from '$lib/features/event-status-management/functions/getVerifiersState.js';
import type { EventWithStatus } from '$lib/types/event/event.interface.js';

export async function load({ params, fetch }) {
	const resProfile = await fetch(`/api/get-profile/${params.username}`);
	const profile = await resProfile.json();

	const getGroups = async (address: string) => {
		const resGroups = await fetch(`/api/groups/${address}?withFloatsIds=true`);
		const groups = await resGroups.json();

		return groups;
	};

	const getEventsWithStatus = async (address: string): Promise<EventWithStatus[]> => {
		const userEvents = await getEvents(address);
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
		userProfile: profile,
		floats: await getFLOATs(profile.address),
		events: await getEventsWithStatus(profile.address),
		groups: await getGroups(profile.address)
		// pinnedFloats: ['187900113', '196985252']
	};
}
