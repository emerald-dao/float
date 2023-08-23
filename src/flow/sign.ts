import { user } from '$stores/flow/FlowStore';
import { ec } from "elliptic";
import scrypt from "scrypt-async";
import { SHA3 } from "sha3";
import { get } from 'svelte/store';
import { Buffer } from 'buffer';

// called directly when creating an event, or as a dependency when claiming
export function getKeysFromClaimCode(claimCode: string, secretSalt: string) {
    let keys;
    scrypt(
        claimCode, //password
        secretSalt, //use some salt for extra security
        {
            N: 16384, // iterations
            r: 8, // block size
            p: 1, // parallelism
            dkLen: 32, // 256-bit key
            encoding: 'hex'
        },
        function (privateKey) {
            var ec_p256 = new ec('p256');
            let kp = ec_p256.keyFromPrivate(privateKey, 'hex'); // hex string, array or Buffer
            var publicKey = kp.getPublic().encode('hex').substr(2);
            keys = { publicKey, privateKey };
        }
    );
    return keys;
}

const rightPaddedHexBuffer = (value, pad) => {
    return Buffer.from(value.padEnd(pad * 2, 0), 'hex');
};

const USER_DOMAIN_TAG = rightPaddedHexBuffer(
    Buffer.from('FLOW-V0.0-user').toString('hex'),
    32
).toString('hex');

const sign = (message, privateKey) => {
    var ec_p256 = new ec('p256');
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
export function signWithClaimCode(claimCode: string, secretSalt: string, claimeeAddress: string) {
    if (!claimCode) {
        return null;
    }

    const { privateKey } = getKeysFromClaimCode(claimCode, secretSalt);
    // let messageToSign = '0x' + get(user).addr.substring(2).replace(/^0+/, '');
    const data = Buffer.from(claimeeAddress).toString('hex');
    const sig = sign(USER_DOMAIN_TAG + data, privateKey);
    return sig;
}