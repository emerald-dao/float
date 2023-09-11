import { createClient } from '@supabase/supabase-js';
import { env as PrivateEnv } from '$env/dynamic/private';
import { env as PublicEnv } from '$env/dynamic/public';
import type { Database } from '$lib/supabase/database.types.js';

const supabase = createClient<Database>(
	PublicEnv.PUBLIC_SUPABASE_API_URL,
	PrivateEnv.PRIVATE_SUPABASE_SERVICE_ROLE
);

export async function GET() {
	const { data: claimsData, error: claimsError } = await supabase
		.from('claims')
		.select('event_id')
		.order('created_at', { ascending: false })
		.limit(50);

	if (claimsError) {
		throw claimsError;
	}

	let mostFrequentEventIds: string[] = [];

	if (claimsData && claimsData.length > 0) {
		// Create a map to count occurrences of each event_id
		const eventCountMap: Record<string, number> = {};
		claimsData.forEach((row) => {
			const eventId = row.event_id;
			if (eventId) {
				eventCountMap[eventId] = (eventCountMap[eventId] || 0) + 1;
			}
		});

		// Sort the event_ids by count in descending order
		const sortedEventIds = Object.keys(eventCountMap).sort(
			(a, b) => eventCountMap[b] - eventCountMap[a]
		);

		// Get the top 6 most frequent event_ids
		mostFrequentEventIds = sortedEventIds.slice(0, 6);
	}

	const { data: eventsData, error: eventsError } = await supabase
		.from('events')
		.select('id , creator_address')
		.in('id', mostFrequentEventIds);

	if (eventsError) {
		throw eventsError;
	}

	const jsonResponse = new Response(JSON.stringify({ eventsData }), {
		status: 200,
		headers: {
			'Content-Type': 'application/json'
		}
	});

	return jsonResponse;
}
