import { getEvent } from '$flow/actions';
import { getFindProfileFromAddressOrName } from '$flow/utils';
import type { Event } from '$lib/types/event/event.interface.js';

export const load = async ({ params }) => {
	const findProfile = await getFindProfileFromAddressOrName(params.username);
	console.log(findProfile)

	let walletAddress = params.username;
	if (findProfile) {
		walletAddress = findProfile.address;
	}
	const event = await getEvent(walletAddress, params.eventId)
	return {
		overview: event
	}
};
