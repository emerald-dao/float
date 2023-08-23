export async function fetchKeysFromClaimCode(claimCode: string) {
    const response = await fetch(`/api/get-keys-from-claim-code/${claimCode}`);
    return await response.json();
}