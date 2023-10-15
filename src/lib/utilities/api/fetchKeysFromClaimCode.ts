import { Buffer } from 'buffer';

export async function fetchKeysFromClaimCode(claimCode: string) {
    const claimCodeAsHex = Buffer.from(claimCode).toString('hex');
    const response = await fetch(`/api/get-keys-from-claim-code/${claimCodeAsHex}`);
    return await response.json();
}