import { createClient } from '@supabase/supabase-js';
import { env as PrivateEnv } from '$env/dynamic/private';
import { env as PublicEnv } from '$env/dynamic/public';
import { verifyAccountOwnership } from '$flow/utils.js';
import type { Database } from '$lib/supabase/database.types.js';
import { network } from '$flow/config';

const supabase = createClient<Database>(
	PublicEnv.PUBLIC_SUPABASE_API_URL,
	PrivateEnv.PRIVATE_SUPABASE_SERVICE_ROLE
);

export async function POST({ request, params }) {
	const data = await request.json();

	// Make sure a valid user was passed in
	const verifyAccount = await verifyAccountOwnership(data.user);
	if (!verifyAccount) {
		return new Response(JSON.stringify({ error: 'Error verifying user' }), { status: 401 });
	}

	const { user, eventId, eventCreatorAddress, blockId, transactionId } = data;

	const { data: existingRow, error } = await supabase.from('events').select('id, network').eq('id', eventId).eq('network', network);

	if (error) {
		return new Response(JSON.stringify({ error: 'Error checking for existing event' }), {
			status: 401
		});
	}

	if (existingRow.length > 0) {
		const { error } = await supabase
			.from('claims')
			.insert({
				float_id: params.claimId,
				user_address: user.addr,
				event_id: eventId,
				block_id: blockId,
				transaction_id: transactionId,
				network
			});

		if (error) {
			return new Response(JSON.stringify({ error: 'Error adding claim' }), { status: 401 });
		} else {
			return new Response(JSON.stringify({ success: 'Claim added' }), { status: 201 });
		}
	} else {
		// If the primary key value doesn't exist, create a new row in the first table
		const { error } = await supabase
			.from('events')
			.insert({ id: eventId, creator_address: eventCreatorAddress, network });

		if (error) {
			return new Response(JSON.stringify({ error: 'Error adding event' }), { status: 401 });
		} else {
			console.log('Event added');

			const { error } = await supabase
				.from('claims')
				.insert({
					float_id: params.claimId,
					user_address: user.addr,
					event_id: eventId,
					block_id: blockId,
					transaction_id: transactionId,
					network
				});

			if (error) {
				return new Response(JSON.stringify({ error: 'Error adding claim' }), { status: 401 });
			} else {
				return new Response(JSON.stringify({ success: 'Claim added' }), { status: 201 });
			}
		}
	}
}
