// vite.config.js
import { sveltekit } from '@sveltejs/kit/vite';
import { nodePolyfills } from 'vite-plugin-node-polyfills'

/** @type {import('vite').UserConfig} */
const config = {
	plugins: [
		nodePolyfills({
      // Whether to polyfill `node:` protocol imports.
      protocolImports: true,
    }),
		sveltekit()
	]
};
export default config;