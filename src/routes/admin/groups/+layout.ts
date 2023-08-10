import { supabase } from '$lib/supabase/supabaseClient';
import { user } from '$stores/flow/FlowStore';
import { get } from 'svelte/store';

export async function load() {
	const fetchGroups = async () => {
		const { data, error } = await supabase
			.from('groups')
			.select('*')
			.eq('user_address', get(user).addr)
			.order('created_at', { ascending: false });

		if (error) {
			console.error(error);
			return [];
		}

		return data;
	};

	return {
		groups: await fetchGroups()
	};
}
