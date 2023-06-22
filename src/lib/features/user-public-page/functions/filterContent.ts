import type { Filter } from '$lib/types/content/filters/filter.interface';
import type { FLOAT } from '$lib/types/float/float.interface';

export const filterContent = async (
	_filters: Filter[],
	contents: FLOAT[],
	activeFilters: {
		typeOfEvent: boolean;
	}
) => {
	let filteredContent = contents;

	if (activeFilters.typeOfEvent) {
		filteredContent = await filterTypeOfEvent(_filters, filteredContent);
	}

	return filteredContent;
};

const filterTypeOfEvent = async (_filters: Filter[], contents: FLOAT[]) => {
	const filter = _filters.filter((flt) => {
		return flt.slug === 'type-of-event';
	});

	return contents.filter((content) => {
		return filter[0].filterBucket.includes(content.eventType) || filter[0].filterBucket.length < 1;
	});
};
