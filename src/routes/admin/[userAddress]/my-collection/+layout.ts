import { getFLOATs } from '$flow/actions.js';

export async function load({ params }) {
	const floats = await getFLOATs(params.userAddress);

	return {
		floats
	};
}
