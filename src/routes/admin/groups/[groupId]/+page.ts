import { supabase } from '$lib/supabase/supabaseClient';

export async function load({ params }) {
	const fetchGroupFloatsIds = async (): Promise<string[]> => {
		const { data, error } = await supabase
			.from('floats_groups')
			.select('float_id')
			.eq('group_id', params.groupId);

		if (error) {
			console.error(error);
			return [];
		}

		return data.map((float) => float.float_id);
	};

	return {
		groups: await fetchGroups()
	};
}
