import { error } from '@sveltejs/kit';

export const load = async ({ params }) => {
	try {
		const overviewFile = await import(`../_mock-data/${params.eventId}.ts`);

		return {
			overview: overviewFile.overview
		};
	} catch (e) {
		throw error(404, 'The event you are looking for does not exist');
	}
};
