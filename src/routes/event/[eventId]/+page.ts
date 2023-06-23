import type { Event } from '$lib/types/event/event.interface.js';
import { error } from '@sveltejs/kit';

export const load = async ({ params }) => {
	try {
		const overviewFile = await import(`../_mock-data/${params.eventId}.ts`);

		return {
			overview: overviewFile.overview as Event
		};
	} catch (e) {
		throw error(404, 'The event you are looking for does not exist');
	}
};
