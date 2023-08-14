import type { Group } from '$lib/features/groups/types/group.interface.js';

export async function load({ params, fetch }) {
	return {
		groups: (await fetch(`/api/groups/${params.userAddress}`).then((res) => res.json())) as Group[]
	};
}
