import { createClient } from '@supabase/supabase-js';
import { env as PrivateEnv } from '$env/dynamic/private';
import { env as PublicEnv } from '$env/dynamic/public';
import type { Database } from '$lib/supabase/database.types.js';

const supabase = createClient<Database>(
	PublicEnv.PUBLIC_SUPABASE_API_URL,
	PrivateEnv.PRIVATE_SUPABASE_SERVICE_ROLE
);

export async function GET({ params }) {
	const { data, error } = await supabase
		.from('events')
		.select('id , creator_address')
		.in('id', [params.eventId]);

	if (error) {
		throw error;
	}
	const jsonResponse = new Response(JSON.stringify(data), {
		status: 200,
		headers: {
			'Content-Type': 'application/json'
		}
	});

	return jsonResponse;
}
