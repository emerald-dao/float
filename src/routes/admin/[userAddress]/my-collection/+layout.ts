import { getFLOATs } from '$flow/actions.js';

export async function load({ params }) {
	const response = await getFLOATs(params.userAddress);

	const floats = response.sort((a, b) => {
		const dateA = parseFloat(a.dateReceived);
		const dateB = parseFloat(b.dateReceived);
		return dateB - dateA;
	});

	return {
		floats
	};
}
