import adapter from '@sveltejs/adapter-auto';
import preprocess from 'svelte-preprocess';

/** @type {import('@sveltejs/kit').Config} */
const config = {
	kit: {
		adapter: adapter(),
		alias: {
			$atoms: 'src/lib/components/atoms/index.ts',
			$stores: 'src/lib/stores/',
			$flow: 'src/flow/'
		}
	},

	preprocess: [
		preprocess({
			postcss: false, // this is turned off because it breaks CSS container query
			scss: {
				prependData: `@import './node_modules/@emerald-dao/component-library/styles/utils/mixins';`
			}
		})
	]
};

export default config;
