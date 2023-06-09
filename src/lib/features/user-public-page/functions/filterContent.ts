import type { Filter } from '$lib/types/content/filters/filter.interface';
import type { Event } from '$lib/types/event/event.interface';

export const filterContent = async (
	_filters: Filter[],
	contents: Event[],
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

const filterTypeOfEvent = async (_filters: Filter[], contents: Event[]) => {
	const filter = _filters.filter((flt) => {
		return flt.slug === 'type-of-event';
	});

	return contents.filter((content) => {
		return filter[0].filterBucket.includes(content.eventType) || filter[0].filterBucket.length < 1;
	});
};
