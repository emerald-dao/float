import { env } from '$env/dynamic/private';
import { json } from '@sveltejs/kit';
import { Buffer } from 'buffer';
import { sign } from '$flow/sign';
import { serviceSupabase } from '$lib/server/supabaseClient';

export async function GET({ params }) {
  const { data: UserEmailData } = await serviceSupabase.from('email').select().eq('event_id', params.eventId).eq('user_address', params.address);

  if (!UserEmailData || UserEmailData.length === 0) {
    return json({ error: 'User has not yet provided their email for this event.' })
  }

  const message = params.address + ' provided email for eventId ' + params.eventId;
  const data = Buffer.from(message).toString('hex');
  const sig = sign(data, env.PRIVATE_EMAIL_VERIFIER_PRIVATE_KEY);
  return json({ sig })
}