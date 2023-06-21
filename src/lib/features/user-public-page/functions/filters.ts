import type { Filter } from '$lib/types/content/filters/filter.interface';
import { EVENT_TYPES } from '$lib/types/event/even-type.type';

export const typeOfEventFilter: Filter = {
	title: 'Type of event',
	slug: 'type-of-event',
	filterElement: [
		{
			icon: 'icon',
			slug: EVENT_TYPES[0]
		},
		{
			icon: 'icon',
			slug: EVENT_TYPES[1]
		},
		{
			icon: 'icon',
			slug: EVENT_TYPES[2]
		},
		{
			icon: 'icon',
			slug: EVENT_TYPES[3]
		}
	],
	filterBucket: []
};

export const createFilters = (activeFilters: { typeOfEvent: boolean }) => {
	const filters = [];

	typeOfEventFilter.filterBucket = [];

	if (activeFilters.typeOfEvent) {
		filters.push(typeOfEventFilter);
	}

	return filters;
};
