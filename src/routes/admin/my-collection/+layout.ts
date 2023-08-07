import { getFLOATs } from '$flow/actions.js';

export async function load() {
	const floats = await getFLOATs('0x99bd48c8036e2876');
	return {
		floats
	};
}
