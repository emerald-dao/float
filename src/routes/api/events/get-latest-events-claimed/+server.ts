import { createClient } from '@supabase/supabase-js';
import { env as PrivateEnv } from '$env/dynamic/private';
import { env as PublicEnv } from '$env/dynamic/public';
import type { Database } from '$lib/supabase/database.types.js';
import { network } from '$flow/config';

const supabase = createClient<Database>(
	PublicEnv.PUBLIC_SUPABASE_API_URL,
	PrivateEnv.PRIVATE_SUPABASE_SERVICE_ROLE
);

export async function GET() {
	const { data: claimsData, error: claimsError } = await supabase
		.from('claims')
		.select('event_id, user_address, float_id, events (*)')
		.eq('network', network)
		.order('created_at', { ascending: false })
		.limit(10);

	if (claimsError) {
		throw claimsError;
	}

	const jsonResponse = new Response(JSON.stringify(claimsData), {
		status: 200,
		headers: {
			'Content-Type': 'application/json'
		}
	});

	return jsonResponse;
}
