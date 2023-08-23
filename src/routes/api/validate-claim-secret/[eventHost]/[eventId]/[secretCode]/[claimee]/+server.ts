import { env } from '$env/dynamic/private';
import { validateSecretCodeForClaim } from '$flow/actions.js';
import { json } from '@sveltejs/kit';

export async function GET({ params }) {
    const valid = await validateSecretCodeForClaim(params.eventId, params.eventHost, params.secretCode, params.claimee, env.SECRET_SALT);
    return json({ valid })
}