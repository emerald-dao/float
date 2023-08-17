import { writable, type Writable } from 'svelte/store';
import { network } from '$flow/config';
import { env } from '$env/dynamic/public';
import type { CurrentUserObject } from '@onflow/fcl';
import type { Profile } from '../../types/user/profile.interface';

const contractData = {
	NonFungibleToken: {
		emulator: '0xf8d6e0586b0a20c7',
		testnet: '0x631e88ae7f1d7c20',
		mainnet: '0x1d7e57aa55817448'
	},
	FungibleTokenMetadataViews: {
		emulator: '0xf8d6e0586b0a20c7',
		testnet: '0x9a0766d93b6608b7',
		mainnet: '0xf233dcee88fe0abe'
	},
	MetadataViews: {
		emulator: '0xf8d6e0586b0a20c7',
		testnet: '0x631e88ae7f1d7c20',
		mainnet: '0x1d7e57aa55817448'
	},
	FungibleToken: {
		emulator: '0xee82856bf20e2aa6',
		testnet: '0x9a0766d93b6608b7',
		mainnet: '0xf233dcee88fe0abe'
	},
	FlowToken: {
		emulator: '0x0ae53cb6e3f42a79',
		testnet: '0x7e60df042a9c0868',
		mainnet: '0x1654653399040a61'
	},
	FUSD: {
		emulator: '0xf8d6e0586b0a20c7',
		testnet: '0xe223d8a629e49c68',
		mainnet: '0x3c5959b568896393'
	},
	FiatToken: {
		emulator: '0xf8d6e0586b0a20c7',
		testnet: '0xa983fecbed621163',
		mainnet: '0xb19436aae4d94622'
	},
	NFTCatalog: {
		emulator: '0xf8d6e0586b0a20c7',
		testnet: '0x324c34e1c517e4db',
		mainnet: '0x49a7cda3a1eecc29'
	},
	ECTreasury: {
		emulator: '0xf8d6e0586b0a20c7',
		testnet: '0x6c0d53c676256e8c',
		mainnet: '0x5643fd47a29770e7'
	},
	FIND: {
		emulator: '0xf8d6e0586b0a20c7',
		testnet: '0xa16ab1d0abde3625',
		mainnet: '0x097bafa4e0b48eef'
	},
	FLOAT: {
		emulator: '0xf8d6e0586b0a20c7',
		testnet: '',
		mainnet: '0x2d4c3caffbeab845'
	}
};

export const user = writable<CurrentUserObject | { loggedIn: false; addr: null }>({
	loggedIn: false,
	addr: null
});
export const profile: Writable<Profile | null> = writable(null);
// export const transactionStatus = writable({});
// export const transactionInProgress = writable(false);
export const addresses: {
	[key: string]: string;
} = {
	NonFungibleToken: contractData.NonFungibleToken[network],
	MetadataViews: contractData.MetadataViews[network],
	FungibleTokenMetadataViews: contractData.FungibleTokenMetadataViews[network],
	FungibleToken: contractData.FungibleToken[network],
	FlowToken: contractData.FlowToken[network],
	FUSD: contractData.FUSD[network],
	ECTreasury: contractData.ECTreasury[network],
	FLOAT: contractData.FLOAT[network],
	FIND: contractData.FIND[network],
	FiatToken: contractData.FiatToken[network],
	NFTCatalog: contractData.NFTCatalog[network]
};
