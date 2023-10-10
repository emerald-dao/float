import { getEvents, getFLOATs, getSpecificFLOATs } from '$flow/actions.js';
import { getEventGeneralStatus } from '$lib/features/event-status-management/functions/helpers/getEventGeneralStatus.js';
import { getVerifiersState } from '$lib/features/event-status-management/functions/helpers/getVerifiersState.js';
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
					generalStatus: getEventGeneralStatus(verifiersStatus)
				}
			};

			eventsWithStatus.push(eventWithStatus);
		}

		return eventsWithStatus;
	};

	const getPinnedFloats = async (
		address: string
	): Promise<
		| {
				float_id: string;
				network: string;
		  }[]
		| null
	> => {
		try {
			const resPinnedFloatsIds = await fetch(`/api/pinned-floats/${address}`);
			const pinnedFloatsIds = await resPinnedFloatsIds.json();

			return pinnedFloatsIds;
		} catch (error) {
			console.error('Error capturing pinned floats:', error);

			return null;
		}
	};

	return {
		userProfile: profile,
		floats: await getFLOATs(profile.address),
		events: await getEventsWithStatus(profile.address),
		groups: await getGroups(profile.address),
		pinnedFloats: await getPinnedFloats(profile.address)
	};
}
