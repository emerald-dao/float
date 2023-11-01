import elliptic from "elliptic";
import { SHA3 } from "sha3";
import { Buffer } from 'buffer';
import { fetchKeysFromClaimCode } from "$lib/utilities/api/fetchKeysFromClaimCode";
import { saveEmail } from "$lib/utilities/api/saveEmail";
import { signUserProvidedEmail } from "$lib/utilities/api/signUserProvidedEmail";

const rightPaddedHexBuffer = (value, pad) => {
    return Buffer.from(value.padEnd(pad * 2, 0), 'hex');
};

export const USER_DOMAIN_TAG = rightPaddedHexBuffer(
    Buffer.from('FLOW-V0.0-user').toString('hex'),
    32
).toString('hex');

export const sign = (message, privateKey) => {
    var ec_p256 = new elliptic.ec('p256');
    const key = ec_p256.keyFromPrivate(Buffer.from(privateKey, 'hex'));
    const sig = key.sign(hash(message)); // hashMsgHex -> hash
    const n = 32;
    const r = sig.r.toArrayLike(Buffer, 'be', n);
    const s = sig.s.toArrayLike(Buffer, 'be', n);
    return Buffer.concat([r, s]).toString('hex');
};

const hash = (message) => {
    const sha = new SHA3(256);
    sha.update(Buffer.from(message, 'hex'));
    return sha.digest();
};

// called when a user is claiming
export async function signWithClaimCode(claimCode: string, claimeeAddress: string) {
    if (!claimCode) {
        return null;
    }

    const { privateKey } = await fetchKeysFromClaimCode(claimCode);
    // let messageToSign = '0x' + get(user).addr.substring(2).replace(/^0+/, '');
    const data = Buffer.from(claimeeAddress).toString('hex');
    const sig = sign(USER_DOMAIN_TAG + data, privateKey);
    return sig;
}

// called when a user is claiming
export async function submitEmailAndGetSig(email: string, claimeeAddress: string, eventId: string) {
    if (!email) {
        return null;
    }

    await saveEmail(email, claimeeAddress, eventId);
    const { sig } = await signUserProvidedEmail(claimeeAddress, eventId);
    return sig;
}