// vite.config.js
import { sveltekit } from '@sveltejs/kit/vite';
import { nodePolyfills } from 'vite-plugin-node-polyfills'
import inject from '@rollup/plugin-inject'

/** @type {import('vite').UserConfig} */
const config = {
	define: {
		global: 'globalThis'
	},
	plugins: [
		nodePolyfills({
      // Whether to polyfill `node:` protocol imports.
      protocolImports: true,
    }),
		sveltekit()
	],
	build: {
		rollupOptions: {
			plugins: [inject({ Buffer: ['Buffer', 'Buffer'] })],
		},
	},
};
export default config;