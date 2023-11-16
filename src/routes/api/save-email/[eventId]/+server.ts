import { network } from '$flow/config';
import { verifyAccountOwnership } from '$flow/utils';
import { serviceSupabase } from '$lib/server/supabaseClient';
import { Buffer } from 'buffer';

export async function POST({ request, params }) {
    const data = await request.json();

    // Make sure a valid user was passed in
    const verifyAccount = await verifyAccountOwnership(data.user);
    if (!verifyAccount) {
        return new Response(JSON.stringify({ error: 'Error verifying user' }), { status: 401 });
    }

    const { data: existingRow } = await serviceSupabase.from('events').select('id, network').eq('id', params.eventId).eq('network', network);
    if (!existingRow || existingRow.length == 0) {
        // If the primary key value doesn't exist, create a new row in the first table
        const { error } = await serviceSupabase
            .from('events')
            .insert({ id: params.eventId, creator_address: data.eventCreatorAddress, network });
        if (error) {
            return new Response(JSON.stringify({ error: 'Error adding event' }), { status: 401 });
        }
    }

    const email = Buffer.from(data.email, 'hex').toString();

    const { error } = await serviceSupabase
        .from('email')
        .upsert({
            event_id: params.eventId,
            user_address: data.user.addr,
            email
        }, { onConflict: 'event_id,user_address' });

    if (error) {
        return new Response(JSON.stringify({ error: 'Error saving email' }), { status: 401 });
    } else {
        return new Response(JSON.stringify({ success: 'Email added' }), { status: 201 });
    }
}