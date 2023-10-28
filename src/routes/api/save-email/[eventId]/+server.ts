import { createClient } from '@supabase/supabase-js';
import { env as PrivateEnv } from '$env/dynamic/private';
import { env as PublicEnv } from '$env/dynamic/public';
import { verifyAccountOwnership } from '$flow/utils.js';
import type { Database } from '$lib/supabase/database.types.js';
import { Buffer } from 'buffer';
import { network } from '$flow/config';

const supabase = createClient<Database>(
  PublicEnv.PUBLIC_SUPABASE_API_URL,
  PrivateEnv.PRIVATE_SUPABASE_SERVICE_ROLE
);

export async function POST({ request, params }) {
  const data = await request.json();

  // Make sure a valid user was passed in
  // const verifyAccount = await verifyAccountOwnership(data.user);
  // if (!verifyAccount) {
  //   return new Response(JSON.stringify({ error: 'Error verifying user' }), { status: 401 });
  // }

  const email = Buffer.from(data.email, 'hex').toString();

  const { error } = await supabase
    .from('email')
    .upsert({
      event_id: params.eventId,
      user_address: data.userAddress,
      email
    }, { onConflict: 'event_id,user_address' });

  if (error) {
    return new Response(JSON.stringify({ error: 'Error saving email' }), { status: 401 });
  } else {
    return new Response(JSON.stringify({ success: 'Email added' }), { status: 201 });
  }
}
