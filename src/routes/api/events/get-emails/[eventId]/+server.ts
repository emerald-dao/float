import { verifyAccountOwnership } from '$flow/utils';
import { userCreatedEvent } from '$flow/actions';
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

  const userOwnsEvent = await userCreatedEvent(params.eventId, user.addr);
  if (!userOwnsEvent) {
    console.log('User does not own event');
    return new Response(JSON.stringify({ error: 'User does not own event' }), { status: 401 });
  }

  const { data: emailsData, error: emailsError } = await serviceSupabase
    .from('email')
    .select('user_address, email')
    .eq('event_id', params.eventId)

  if (emailsError) {
    throw emailsError;
  }

  return new Response(JSON.stringify(emailsData), {
    status: 200,
    headers: {
      'Content-Type': 'application/json'
    }
  });
}
