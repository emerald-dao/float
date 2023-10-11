import type { Database } from '$lib/supabase/database.types.js';
import { createClient } from '@supabase/supabase-js';
import { env as PrivateEnv } from '$env/dynamic/private';
import { env as PublicEnv } from '$env/dynamic/public';
import { error as err } from '@sveltejs/kit';

const supabase = createClient<Database>(
	PublicEnv.PUBLIC_SUPABASE_API_URL,
	PrivateEnv.PRIVATE_SUPABASE_SERVICE_ROLE
);

export async function GET({ params }) {
	const { userAddress } = params;

	const { data, error } = await supabase
		.from('pinned_floats')
		.select('float_id, network')
		.eq('user_address', userAddress);

	if (error) {
		throw err(400, "Couldn't fetch groups");
	}

	return new Response(JSON.stringify(data));
}
