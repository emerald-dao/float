import { user } from '$stores/flow/FlowStore';
import { Buffer } from 'buffer';
import { get } from 'svelte/store';

export async function saveEmail(email: string, eventId: string, eventCreatorAddress: string) {
    // first, save the email
    const emailAsHex = Buffer.from(email).toString('hex');
    const res = await fetch(`/api/save-email/${eventId}`, {
        method: 'POST',
        body: JSON.stringify({
            user: get(user),
            email: emailAsHex,
            eventCreatorAddress
        }),
        headers: {
            'content-type': 'application/json'
        }
    });

    const response = await res.json();
    return response;
}