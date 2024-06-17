import { network } from '$flow/config';
import { serviceSupabase } from '$lib/server/supabaseClient';

export async function GET() {
	const { data: claimsData, error: claimsError } = await serviceSupabase
		.from('float_claims')
		.select('event_id, user_address, float_id, serial, float_events (*)')
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
