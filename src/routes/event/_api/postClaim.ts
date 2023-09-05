import type { User } from '@emerald-dao/component-library/models/user.interface';

export const postClaim = async (
	claimId: string,
	userObject: User,
	eventId: string,
	eventCreatorAddress: string
) => {
	const res = await fetch(`/api/claims/${claimId}`, {
		method: 'POST',
		body: JSON.stringify({
			user: userObject,
			eventId,
			eventCreatorAddress
		}),
		headers: {
			'content-type': 'application/json'
		}
	});

	const response = await res.json();

	return response;
};
