// vite.config.js
import { sveltekit } from '@sveltejs/kit/vite';
import { nodePolyfills } from 'vite-plugin-node-polyfills'
import resolve from '@rollup/plugin-node-resolve'

/** @type {import('vite').UserConfig} */
const config = {
	define: {
		global: 'globalThis'
	},
	plugins: [
		resolve({ preferBuiltins: false }),
		nodePolyfills({
      // Whether to polyfill `node:` protocol imports.
      protocolImports: true,
    }),
		sveltekit()
	]
};
export default config;	