import type { GroupWithFloatsIds } from '$lib/features/groups/types/group.interface.js';

export async function load({ params, fetch }) {
	return {
		group: (await fetch(
			`/api/groups/${params.userAddress}/${params.groupId}?withFloatsIds=true`
		).then((res) => res.json())) as GroupWithFloatsIds
	};
}
