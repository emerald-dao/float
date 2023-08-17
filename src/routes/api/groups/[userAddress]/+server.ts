import type { Group, GroupWithFloatsIds } from '$lib/features/groups/types/group.interface.js';
import { supabase } from '$lib/supabase/supabaseClient.js';
import { error as err } from '@sveltejs/kit';

export async function GET({ url, params }) {
	const { userAddress } = params;

	const withFloatsIds = url.searchParams.get('withFloatsIds');

	if (withFloatsIds) {
		const { data, error } = await supabase
			.from('groups')
			.select(`*, floats_groups (float_id)`)
			.eq('user_address', userAddress)
			.order('created_at', { ascending: false });

		if (error) {
			throw err(400, "Couldn't fetch groups");
		}

		const shapedData: GroupWithFloatsIds[] = data.map((group) => {
			const { floats_groups, ...rest } = group;
			return { ...rest, floatsIds: floats_groups.map((float) => float.float_id) };
		});

		return new Response(JSON.stringify(shapedData));
	} else {
		const { data, error } = await supabase
			.from('groups')
			.select('*')
			.eq('user_address', userAddress)
			.order('created_at', { ascending: false });

		if (error) {
			throw err(400, "Couldn't fetch groups");
		}

		return new Response(JSON.stringify(data as Group[]));
	}
}
