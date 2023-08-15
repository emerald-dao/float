import * as fcl from '@onflow/fcl';
import { transactionStore } from '$stores/flow/TransactionStore';
import { addresses } from '$stores/flow/FlowStore';
import { network } from './config.js';
import type { TransactionStatusObject } from '@onflow/fcl';
import type { ActionExecutionResult } from '$lib/stores/custom/steps/step.interface';

export function replaceWithProperValues(script: string, contractName = '', contractAddress = '') {
	return (
		script
			// For Tx/Scripts
			.replace('"../ExampleToken.cdc"', contractAddress)
			.replace('"../utility/NonFungibleToken.cdc"', addresses.NonFungibleToken)
			.replace('"../utility/MetadataViews.cdc"', addresses.MetadataViews)
			.replace('"../utility/FlowToken.cdc"', addresses.FlowToken)
			.replace('"../utility/FiatToken.cdc"', addresses.FiatToken)
			.replace('"../utility/FungibleToken.cdc"', addresses.FungibleToken)
			.replace('"../utility/FIND.cdc"', addresses.FIND)
			.replace('"../utility/FLOAT.cdc"', addresses.FLOAT)
			.replace('"../FLOAT.cdc"', addresses.FLOAT)
			.replace('"../FLOATVerifiers.cdc"', addresses.FLOAT)
			.replace('"../utility/NFTCatalog.cdc"', addresses.NFTCatalog)
			// For All
			.replaceAll('ExampleToken', contractName)
			.replaceAll('0x5643fd47a29770e7', addresses.ECTreasury)
	);
}

export const executeTransaction: (
	transaction: () => Promise<string>,
	actionAfterSucceed?: (res: TransactionStatusObject) => Promise<ActionExecutionResult>
) => Promise<ActionExecutionResult> = async (transaction, actionAfterSucceed) => {
	transactionStore.initTransaction();

	try {
		// We start the transaction
		const transactionId = await transaction();
		console.log('Transaction Id', transactionId);

		// We connect our TransactionStore to the transaction to get the status
		fcl.tx(transactionId).subscribe(async (res: TransactionStatusObject) => {
			console.log(res);
			transactionStore.subscribeTransaction(res);
		});

		// We wait for the transaction to be sealed to get the result
		const executionResult = (await fcl.tx(transactionId).onceSealed()) as TransactionStatusObject;

		// Once sealed, we check if the execution has an actionAfterSucceed, if so, we execute it
		if (actionAfterSucceed) {
			try {
				// We execute the actionAfterSucceed and return the result
				const action = await actionAfterSucceed(executionResult);

				setTimeout(() => {
					transactionStore.resetTransaction();
				}, 1000);

				return action;
			} catch (e) {
				transactionStore.resetTransaction();

				return {
					state: 'error',
					errorMessage: 'Error executing actionAfterSucceed: ' + e
				} as ActionExecutionResult;
			}
		} else {
			setTimeout(() => {
				transactionStore.resetTransaction();
			}, 1000);

			return {
				state: 'success',
				errorMessage: ''
			} as ActionExecutionResult;
		}
	} catch (e) {
		transactionStore.subscribeTransaction({
			blockId: '',
			events: [],
			status: 4,
			statusString: '',
			errorMessage: e as string,
			statusCode: 1
		});

		setTimeout(() => {
			transactionStore.resetTransaction();
		}, 6000);

		console.log('Error in executeTransaction: ', e);

		return {
			state: 'error',
			errorMessage: e
		} as ActionExecutionResult;
	}
};

export const getFindProfile = async (address: string) => {
	try {
		return await fcl.query({
			cadence: `
        import FIND from ${addresses.FIND}
        pub fun main(address: Address): Profile? {
            if let name = FIND.reverseLookup(address) {
              let profile = FIND.lookup(name)!
              return Profile(_name: name, _address: address, _avatar: profile.getAvatar())
            }
            
            return nil
        }

        pub struct Profile {
          pub let name: String
          pub let address: Address
          pub let avatar: String

          init(_name: String, _address: Address, _avatar: String) {
            self.name = _name
            self.address = _address
            self.avatar = _avatar
          }
        }
        `,
			args: (arg, t) => [arg(address, t.Address)]
		});
	} catch (e) {
		return null;
	}
};

export const getFindProfileFromAddressOrName = async (input: string) => {
	try {
		let cadence = '';
		let args;
		if (input.length === 18 && input.substring(0, 2) === '0x') {
			cadence = `
			import FIND from ${addresses.FIND}
			pub fun main(address: Address): Profile? {
				if let name = FIND.reverseLookup(address) {
					if let profile = FIND.lookup(name) {
						return Profile(_name: name, _address: address, _avatar: profile.getAvatar())
					}
				}
				
				return nil
			}

			pub struct Profile {
				pub let name: String
				pub let address: Address
				pub let avatar: String

				init(_name: String, _address: Address, _avatar: String) {
					self.name = _name
					self.address = _address
					self.avatar = _avatar
				}
			}
			`
			args = (arg, t) => [arg(input, t.Address)]
		} else {
			cadence = `
			import FIND from ${addresses.FIND}
			pub fun main(name: String): Profile? {
				if let profile = FIND.lookup(name) {
					return Profile(_name: name, _address: profile.getAddress(), _avatar: profile.getAvatar())
				}
				
				return nil
			}

			pub struct Profile {
				pub let name: String
				pub let address: Address
				pub let avatar: String

				init(_name: String, _address: Address, _avatar: String) {
					self.name = _name
					self.address = _address
					self.avatar = _avatar
				}
			}
			`
			args = (arg, t) => [arg(input, t.String)]
		}
		return await fcl.query({
			cadence,
			args
		});
	} catch (e) {
		return null;
	}
}

// export function getKeysFromClaimCode(claimCode) {
// 	let keys;
// 	scrypt(
// 		claimCode, //password
// 		secretSalt, //use some salt for extra security
// 		{
// 			N: 16384, // iterations
// 			r: 8, // block size
// 			p: 1, // parallelism
// 			dkLen: 32, // 256-bit key
// 			encoding: 'hex'
// 		},
// 		function (privateKey) {
// 			var ec_p256 = new ec('p256');
// 			let kp = ec_p256.keyFromPrivate(privateKey, 'hex'); // hex string, array or Buffer
// 			var publicKey = kp.getPublic().encode('hex').substr(2);
// 			keys = { publicKey, privateKey };
// 		}
// 	);
// 	return keys;
// }

// const rightPaddedHexBuffer = (value, pad) => {
// 	return Buffer.from(value.padEnd(pad * 2, 0), 'hex');
// };

// const USER_DOMAIN_TAG = rightPaddedHexBuffer(
// 	Buffer.from('FLOW-V0.0-user').toString('hex'),
// 	32
// ).toString('hex');

// const sign = (message, privateKey) => {
// 	var ec_p256 = new ec('p256');
// 	const key = ec_p256.keyFromPrivate(Buffer.from(privateKey, 'hex'));
// 	const sig = key.sign(hash(message)); // hashMsgHex -> hash
// 	const n = 32;
// 	const r = sig.r.toArrayLike(Buffer, 'be', n);
// 	const s = sig.s.toArrayLike(Buffer, 'be', n);
// 	return Buffer.concat([r, s]).toString('hex');
// };

// const hash = (message) => {
// 	const sha = new SHA3(256);
// 	sha.update(Buffer.from(message, 'hex'));
// 	return sha.digest();
// };

// export function signWithClaimCode(claimCode) {
// 	if (!claimCode) {
// 		return null;
// 	}

// 	const { privateKey } = getKeysFromClaimCode(claimCode);
// 	// let messageToSign = '0x' + get(user).addr.substring(2).replace(/^0+/, '');
// 	const data = Buffer.from(get(user).addr).toString('hex');
// 	const sig = sign(USER_DOMAIN_TAG + data, privateKey);
// 	return sig;
// }
