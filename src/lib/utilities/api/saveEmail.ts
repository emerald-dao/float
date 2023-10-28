import { Buffer } from 'buffer';

export async function saveEmail(email: string, userAddress: string, eventId: string) {
    // first, save the email
    const emailAsHex = Buffer.from(email).toString('hex');
    const res = await fetch(`/api/save-email/${eventId}`, {
        method: 'POST',
        body: JSON.stringify({
            userAddress,
            email: emailAsHex
        }),
        headers: {
            'content-type': 'application/json'
        }
    });

    const response = await res.json();
    return response;
}