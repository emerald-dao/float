import { createClient } from '@supabase/supabase-js';
import { env as PrivateEnv } from '$env/dynamic/private';
import { env as PublicEnv } from '$env/dynamic/public';
import type { Database } from '$lib/supabase/database.types.js';

const supabase = createClient<Database>(
  PublicEnv.PUBLIC_SUPABASE_API_URL,
  PrivateEnv.PRIVATE_SUPABASE_SERVICE_ROLE
);

export async function GET({ params }) {
  const { data: emailsData, error: emailsError } = await supabase
    .from('email')
    .select('user_address, email')
    .eq('event_id', params.eventId)

  if (emailsError) {
    throw emailsError;
  }

  const jsonResponse = new Response(JSON.stringify(emailsData), {
    status: 200,
    headers: {
      'Content-Type': 'application/json'
    }
  });

  return jsonResponse;
}
