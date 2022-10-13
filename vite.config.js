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
		nodePolyfills({
      // Whether to polyfill `node:` protocol imports.
      protocolImports: true,
    }),
		resolve({ preferBuiltins: false }),
		sveltekit()
	],
	build: {
    rollupOptions: {
      external: [
        "Buffer",
      ],
    },
  },
};
export default config;	