import { env } from '$env/dynamic/private';
import { json } from '@sveltejs/kit';
import scrypt from "scrypt-async";
import { ec } from "elliptic";

// called directly when creating an event, or as a dependency when claiming
function getKeysFromClaimCode(claimCode: string) {
    let keys;
    scrypt(
        claimCode, //password
        env.SECRET_SALT, //use some salt for extra security
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

export async function GET({ params }) {
    const { publicKey, privateKey } = getKeysFromClaimCode(params.claimCode);
    return json({ publicKey, privateKey })
}