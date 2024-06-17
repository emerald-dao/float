import { verifyAccountOwnership } from '$flow/utils.js';
import { network } from '$flow/config';
import { serviceSupabase } from '$lib/server/supabaseClient';

export async function POST({ request, params }) {
	const data = await request.json();

	// Make sure a valid user was passed in
	const verifyAccount = await verifyAccountOwnership(data.user);
	if (!verifyAccount) {
		return new Response(JSON.stringify({ error: 'Error verifying user' }), { status: 401 });
	}

	const { user, eventId, eventCreatorAddress, blockId, transactionId, serial } = data;

	const { data: existingRow, error } = await serviceSupabase
		.from('float_events')
		.select('id, network')
		.eq('id', eventId)
		.eq('network', network);

	if (error) {
		return new Response(JSON.stringify({ error: 'Error checking for existing event' }), {
			status: 401
		});
	}

	if (existingRow.length > 0) {
		const { error } = await serviceSupabase.from('float_claims').insert({
			float_id: params.claimId,
			user_address: user.addr,
			event_id: eventId,
			block_id: blockId,
			transaction_id: transactionId,
			network,
			serial
		});

		if (error) {
			return new Response(JSON.stringify({ error: 'Error adding claim' }), { status: 401 });
		} else {
			return new Response(JSON.stringify({ success: 'Claim added' }), { status: 201 });
		}
	} else {
		// If the primary key value doesn't exist, create a new row in the first table
		const { error } = await serviceSupabase
			.from('float_events')
			.insert({ id: eventId, creator_address: eventCreatorAddress, network });

		if (error) {
			return new Response(JSON.stringify({ error: 'Error adding event' }), { status: 401 });
		} else {
			console.log('Event added');

			const { error } = await serviceSupabase.from('float_claims').insert({
				float_id: params.claimId,
				user_address: user.addr,
				event_id: eventId,
				block_id: blockId,
				transaction_id: transactionId,
				network,
				serial
			});

			if (error) {
				return new Response(JSON.stringify({ error: 'Error adding claim' }), { status: 401 });
			} else {
				return new Response(JSON.stringify({ success: 'Claim added' }), { status: 201 });
			}
		}
	}
}
