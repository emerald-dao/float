import { getEvents, getFLOATs } from '$flow/actions.js';

export async function load({ params, fetch }) {
	const res = await fetch(`/api/get-profile/${params.username}`);
	const profile = await res.json();

	return {
		userProfile: profile,
		floats: await getFLOATs(profile.address),
		events: await getEvents(profile.address),
		pinnedFloats: ['187900113', '196985252']
	};
}
