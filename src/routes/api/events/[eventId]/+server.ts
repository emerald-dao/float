import { createClient } from '@supabase/supabase-js';
import { env as PrivateEnv } from '$env/dynamic/private';
import { env as PublicEnv } from '$env/dynamic/public';
import { verifyAccountOwnership } from '$flow/utils.js';
import type { Database } from '$lib/supabase/database.types.js';

const supabase = createClient<Database>(
	PublicEnv.PUBLIC_SUPABASE_API_URL,
	PrivateEnv.PRIVATE_SUPABASE_SERVICE_ROLE
);

export async function POST({ request, params }) {
	const data = await request.json();
	const { user } = data;

	// Make sure a valid user was passed in
	const verifyAccount = await verifyAccountOwnership(user);
	if (!verifyAccount) {
		console.log('Error verifying user');
		return new Response(JSON.stringify({ error: 'Error verifying user' }), { status: 401 });
	}

	const { error } = await supabase.from('events').insert({
		id: params.eventId,
		creator_address: user.addr
	});

	if (error) {
		console.log(error);
		return new Response(JSON.stringify({ error: 'Error adding event' }), { status: 401 });
	} else {
		console.log('Event added');
		return new Response(JSON.stringify({ success: 'Event added' }), { status: 201 });
	}
}
