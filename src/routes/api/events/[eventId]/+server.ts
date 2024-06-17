import { verifyAccountOwnership } from '$flow/utils.js';
import { network } from '$flow/config';
import { serviceSupabase } from '$lib/server/supabaseClient';

export async function POST({ request, params }) {
	const data = await request.json();
	const { user } = data;

	// Make sure a valid user was passed in
	const verifyAccount = await verifyAccountOwnership(user);
	if (!verifyAccount) {
		console.log('Error verifying user');
		return new Response(JSON.stringify({ error: 'Error verifying user' }), { status: 401 });
	}

	const { error } = await serviceSupabase.from('float_events').insert({
		id: params.eventId,
		creator_address: user.addr,
		network
	});

	if (error) {
		console.log(error);
		return new Response(JSON.stringify({ error: 'Error adding event' }), { status: 401 });
	} else {
		console.log('Event added');
		return new Response(JSON.stringify({ success: 'Event added' }), { status: 201 });
	}
}

export async function GET({ params }) {
	const { data, error } = await serviceSupabase
		.from('float_events')
		.select('id , creator_address, network')
		.eq('network', network)
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
