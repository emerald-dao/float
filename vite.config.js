// vite.config.js
import { sveltekit } from '@sveltejs/kit/vite';

/** @type {import('vite').UserConfig} */
const config = {
	optimizeDeps: {
		include: ['lodash.get', 'lodash.isequal', 'lodash.clonedeep']
	},
	assetsInclude: ['**/*.cdc'],
	plugins: [sveltekit()],

	// Fixes issue with @onflow/fcl. "node-fetch" couldn't be used in client, so replaced it with "isomorphic-fetch"
	resolve: {
		alias: {
			'node-fetch': 'isomorphic-fetch'
		}
	}
};

export default config;
