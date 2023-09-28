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
		.select('event_id, user_address, network')
		.eq('network', network)
		.order('created_at', { ascending: false })
		.limit(10);

	if (claimsError) {
		throw claimsError;
	}
	let latestClaims = claimsData.map((claim) => claim.event_id);

	let latestUsersToClaim = claimsData.map((claim) => claim.user_address);

	const eventsPromises = latestClaims.map(async (eventId) => {
		const { data: eventData, error: eventsError } = await supabase
			.from('events')
			.select('id, creator_address, network')
			.eq('id', [eventId])
			.eq('network', network)
			.single();

		if (eventsError) {
			throw eventsError;
		}

		return eventData;
	});

	const eventsData = await Promise.all(eventsPromises);

	let data = {
		eventsData,
		latestUsersToClaim
	};

	const jsonResponse = new Response(JSON.stringify(data), {
		status: 200,
		headers: {
			'Content-Type': 'application/json'
		}
	});

	return jsonResponse;
}
