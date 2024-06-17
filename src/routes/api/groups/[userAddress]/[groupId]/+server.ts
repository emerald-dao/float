import type { Group, GroupWithFloatsIds } from '$lib/features/groups/types/group.interface.js';
import { supabase } from '$lib/supabase/supabaseClient.js';
import { error as err } from '@sveltejs/kit';

export async function GET({ url, params }) {
	const { userAddress, groupId } = params;

	const withFloatsIds = url.searchParams.get('withFloatsIds');

	if (withFloatsIds) {
		const { data, error } = await supabase
			.from('float_groups')
			.select(`*, float_floats_groups (float_id)`)
			.eq('user_address', userAddress)
			.eq('id', groupId)
			.single();

		if (error) {
			throw err(400, "Couldn't fetch group");
		}

		const shapedData: GroupWithFloatsIds = {
			...data,
			floatsIds: data.float_floats_groups.map((float) => float.float_id)
		};

		return new Response(JSON.stringify(shapedData));
	} else {
		const { data, error } = await supabase
			.from('float_groups')
			.select('*')
			.eq('user_address', userAddress)
			.eq('id', groupId)
			.single();

		if (error) {
			throw err(400, "Couldn't fetch group");
		}

		return new Response(JSON.stringify(data as Group));
	}
}
