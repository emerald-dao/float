import { getFindProfileFromAddressOrName } from '$flow/utils.js';

export async function load() {
	const user = getFindProfileFromAddressOrName('0x99bd48c8036e2876');

	return {
		user
	};
}
