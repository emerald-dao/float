import type { Filter } from '$lib/types/content/filters/filter.interface';
import type { EventWithStatus } from '$lib/types/event/event.interface';

export const filterEventsContent = async (
	_filters: Filter[],
	contents: EventWithStatus[],
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

const filterTypeOfEvent = async (_filters: Filter[], contents: EventWithStatus[]) => {
	const filter = _filters.filter((flt) => {
		return flt.slug === 'type-of-event';
	});

	return contents.filter((content) => {
		return filter[0].filterBucket.includes(content.eventType) || filter[0].filterBucket.length < 1;
	});
};
