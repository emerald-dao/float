import { serviceSupabase } from '$lib/server/supabaseClient';
import { error as err } from '@sveltejs/kit';

export async function GET({ params }) {
	const { userAddress } = params;

	const { data, error } = await serviceSupabase
		.from('float_pinned_floats')
		.select('float_id, network')
		.eq('user_address', userAddress);

	if (error) {
		throw err(400, "Couldn't fetch groups");
	}

	return new Response(JSON.stringify(data));
}
