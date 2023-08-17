import { getEvent, getEventClaims } from '$flow/actions';
import { getFindProfileFromAddressOrName } from '$flow/utils';

export const load = async ({ params }) => {
	const findProfile = await getFindProfileFromAddressOrName(params.username);

	let walletAddress = params.username;

	if (findProfile) {
		walletAddress = findProfile.address;
	}

	const getLatestClaims = async (address: string, eventId: string) => {
		const eventClaims = await getEventClaims(address, eventId);
		const latestClaims = Object.values(eventClaims)
			.sort((a, b) => Number(b.serial) - Number(a.serial))
			.slice(0, 20);

		return latestClaims;
	};

	return {
		overview: await getEvent(walletAddress, params.eventId),
		claims: await getLatestClaims(walletAddress, params.eventId)
	};
};
