import { env as PrivateEnv } from '$env/dynamic/private';
import { env as PublicEnv } from '$env/dynamic/public';
import { json } from '@sveltejs/kit';
import { Buffer } from 'buffer';
import { USER_DOMAIN_TAG, sign } from '$flow/sign';
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(PublicEnv.PUBLIC_SUPABASE_API_URL, PrivateEnv.PRIVATE_SUPABASE_SERVICE_ROLE);

export async function GET({ params }) {
  const { data: UserEmailData } = await supabase.from('email').select().eq('event_id', params.eventId).eq('user_address', params.address);

  if (!UserEmailData || UserEmailData.length === 0) {
    return json({ error: 'User has not yet provided their email for this event.' })
  }

  const message = params.address + ' provided email for eventId ' + params.eventId;
  const data = Buffer.from(message).toString('hex');
  const sig = sign(USER_DOMAIN_TAG + data, PrivateEnv.PRIVATE_EMAIL_VERIFIER_PRIVATE_KEY);
  return json({ sig })
}