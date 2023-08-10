import { redirect } from '@sveltejs/kit';
import { supabase } from '$lib/supabase/supabaseClient';
import { get } from 'svelte/store';
import { user } from '$stores/flow/FlowStore';

export const load = async () => {
	const fetchOneGroup = async () => {
		const { data, error } = await supabase
			.from('groups')
			.select('*')
			.eq('user_address', get(user).addr)
			.limit(1)
			.single();

		if (error) {
			console.error(error);
			return null;
		}

		return data;
	};

	const group = await fetchOneGroup();

	if (group === null) {
		throw redirect(302, '/admin/groups/new-group');
	} else {
		throw redirect(302, `/admin/groups/${group.id}`);
	}
};
