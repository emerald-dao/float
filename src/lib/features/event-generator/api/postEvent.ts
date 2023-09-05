import type { User } from '@emerald-dao/component-library/models/user.interface';

export const postEvent = async (eventId: string, userObject: User) => {
	const res = await fetch(`/api/events/${eventId}`, {
		method: 'POST',
		body: JSON.stringify({
			user: userObject
		}),
		headers: {
			'content-type': 'application/json'
		}
	});

	const response = await res.json();

	return response;
};
