import { supabase } from '$lib/supabase/supabaseClient';

export async function load() {
	const fetchGroups = async () => {
		const { data, error } = await supabase
			.from('groups')
			.select('*')
			.eq('user_address', '0x99bd48c8036e2876');

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
