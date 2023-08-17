import { getEvents, getFLOATs } from '$flow/actions.js';

export async function load({ params, fetch }) {
	const resProfile = await fetch(`/api/get-profile/${params.username}`);
	const profile = await resProfile.json();

	const getGroups = async (address: string) => {
		const resGroups = await fetch(`/api/groups/${address}?withFloatsIds=true`);
		const groups = await resGroups.json();

		return groups;
	};

	return {
		userProfile: profile,
		floats: await getFLOATs(profile.address),
		events: await getEvents(profile.address),
		groups: await getGroups(profile.address),
		pinnedFloats: ['187900113', '196985252']
	};
}
