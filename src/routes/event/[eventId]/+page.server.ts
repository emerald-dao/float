import { error } from '@sveltejs/kit';

export const load = async ({ params }) => {
	try {
		const overviewFile = await import(`../../../lib/mocks/${params.eventId}.ts`);

		return {
			overview: overviewFile.overview
		};
	} catch (e) {
		throw error(404, 'The event you are looking for does not exist');
	}
};
