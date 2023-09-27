import { config } from '@onflow/fcl';
import dappInfo from '$lib/config/config';
import { env } from '$env/dynamic/public';

const resolver = async () => {
	return {
		appIdentifier: 'FLOAT',
		nonce: env.PUBLIC_NONCE
	};
};

export const network: 'mainnet' | 'testnet' | 'emulator' = env.PUBLIC_FLOW_NETWORK as
	| 'mainnet'
	| 'testnet'
	| 'emulator';

const fclConfigInfo = {
	emulator: {
		accessNode: 'http://127.0.0.1:8888',
		discoveryWallet: 'http://localhost:8701/fcl/authn',
		discoveryAuthInclude: []
	},
	testnet: {
		accessNode: 'https://rest-testnet.onflow.org',
		discoveryWallet: 'https://fcl-discovery.onflow.org/testnet/authn',
		discoveryAuthInclude: []
	},
	mainnet: {
		accessNode: 'https://rest-mainnet.onflow.org',
		discoveryWallet: 'https://fcl-discovery.onflow.org/authn',
		discoveryAuthInclude: ["0xead892083b3e2c6c"]
	}
};

config({
	'app.detail.title': dappInfo.title,
	'app.detail.icon': dappInfo.icon,
	'fcl.accountProof.resolver': resolver,
	'flow.network': network,
	'accessNode.api': fclConfigInfo[network].accessNode,
	'discovery.wallet': fclConfigInfo[network].discoveryWallet,
	"discovery.authn.include": fclConfigInfo[network].discoveryAuthInclude, // include Dapper Wallet
});
