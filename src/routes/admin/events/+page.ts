import { getEvents } from '$flow/actions.js';

export async function load() {
	const events = await getEvents('0x99bd48c8036e2876');

	return {
		events
	};
}
