import * as fcl from '@onflow/fcl';
import { transactionStore } from '$stores/flow/TransactionStore';
import { addresses } from '$stores/flow/FlowStore';
import type { TransactionStatusObject } from '@onflow/fcl';
import type { ActionExecutionResult } from '$lib/stores/custom/steps/step.interface';
import type { User } from '@emerald-dao/component-library/models/user.interface';
import { network } from './config';

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
			transactionStore.subscribeTransaction(res, transactionId);
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
		}, '');

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
			import EmeraldIdentity from ${addresses.EmeraldIdentity}
			import EmeraldIdentityDapper from ${addresses.EmeraldIdentity}
			import EmeraldIdentityLilico from ${addresses.EmeraldIdentity}
			pub fun main(address: Address): Profile? {
				if let name = FIND.reverseLookup(address) {
					if let profile = FIND.lookup(name) {
						return Profile(_name: name, _address: address, _avatar: profile.getAvatar())
					}
				}

				if let discordId: String = EmeraldIdentity.getDiscordFromAccount(account: address) {
					let miniProfile: MiniProfile? = helper(discordId: discordId)
					return miniProfile != nil ? Profile(_name: miniProfile!.name, _address: address, _avatar: miniProfile!.avatar) : nil
				}

				if let discordId: String = EmeraldIdentityDapper.getDiscordFromAccount(account: address) {
					let miniProfile: MiniProfile? = helper(discordId: discordId)
					return miniProfile != nil ? Profile(_name: miniProfile!.name, _address: address, _avatar: miniProfile!.avatar) : nil
				}

				if let discordId: String = EmeraldIdentityLilico.getDiscordFromAccount(account: address) {
					let miniProfile: MiniProfile? = helper(discordId: discordId)
					return miniProfile != nil ? Profile(_name: miniProfile!.name, _address: address, _avatar: miniProfile!.avatar) : nil
				}
				
				return nil
			}

			pub fun helper(discordId: String): MiniProfile? {
				let emeraldIDs: [Address] = EmeraldIdentity.getEmeraldIDs(discordID: discordId).values
					for emeraldIDAddress in emeraldIDs {
						if let name = FIND.reverseLookup(emeraldIDAddress) {
							if let profile = FIND.lookup(name) {
								return MiniProfile(_name: name,  _avatar: profile.getAvatar())
							}
						}
					}
					return nil
			}

			pub struct MiniProfile {
				pub let name: String
				pub let avatar: String

				init(_name: String, _avatar: String) {
					self.name = _name
					self.avatar = _avatar
				}
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
		console.log(e)
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
			import EmeraldIdentity from ${addresses.EmeraldIdentity}
			import EmeraldIdentityDapper from ${addresses.EmeraldIdentity}
			import EmeraldIdentityLilico from ${addresses.EmeraldIdentity}
			pub fun main(address: Address): Profile? {
				if let name = FIND.reverseLookup(address) {
					if let profile = FIND.lookup(name) {
						return Profile(_name: name, _address: address, _avatar: profile.getAvatar())
					}
				}

				if let discordId: String = EmeraldIdentity.getDiscordFromAccount(account: address) {
					let miniProfile: MiniProfile? = helper(discordId: discordId)
					return miniProfile != nil ? Profile(_name: miniProfile!.name, _address: address, _avatar: miniProfile!.avatar) : nil
				}

				if let discordId: String = EmeraldIdentityDapper.getDiscordFromAccount(account: address) {
					let miniProfile: MiniProfile? = helper(discordId: discordId)
					return miniProfile != nil ? Profile(_name: miniProfile!.name, _address: address, _avatar: miniProfile!.avatar) : nil
				}

				if let discordId: String = EmeraldIdentityLilico.getDiscordFromAccount(account: address) {
					let miniProfile: MiniProfile? = helper(discordId: discordId)
					return miniProfile != nil ? Profile(_name: miniProfile!.name, _address: address, _avatar: miniProfile!.avatar) : nil
				}
				
				return nil
			}

			pub fun helper(discordId: String): MiniProfile? {
				let emeraldIDs: [Address] = EmeraldIdentity.getEmeraldIDs(discordID: discordId).values
					for emeraldIDAddress in emeraldIDs {
						if let name = FIND.reverseLookup(emeraldIDAddress) {
							if let profile = FIND.lookup(name) {
								return MiniProfile(_name: name,  _avatar: profile.getAvatar())
							}
						}
					}
					return nil
			}

			pub struct MiniProfile {
				pub let name: String
				pub let avatar: String

				init(_name: String, _avatar: String) {
					self.name = _name
					self.avatar = _avatar
				}
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
			`;
			args = (arg, t) => [arg(input, t.Address)];
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
			`;
			args = (arg, t) => [arg(input, t.String)];
		}
		return await fcl.query({
			cadence,
			args
		});
	} catch (e) {
		console.log(e)
		return null;
	}
};

export const verifyAccountOwnership = async (userObject: User) => {
	if (!userObject.loggedIn) {
		return false;
	}
	const accountProofService = userObject.services.find(
		(services) => services.type === 'account-proof'
	);

	const fclCryptoContract = {
		emulator: "0xf8d6e0586b0a20c7",
		testnet: "0x5b250a8a85b44a67",
		mainnet: "0xdb6b70764af4ff68"
	}[network];
	return await fcl.AppUtils.verifyAccountProof('FLOAT', accountProofService.data, {
		fclCryptoContract
	});
};
