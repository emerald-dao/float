// vite.config.js
import { sveltekit } from '@sveltejs/kit/vite';
/** @type {import('vite').UserConfig} */
const config = {
	assetsInclude: ["**/*.cdc"],
	plugins: [sveltekit()]
};
export default config;