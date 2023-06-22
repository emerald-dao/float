import type { Filter } from '$lib/types/content/filters/filter.interface';

export const createFilters = (activeFilters: { typeOfEvent: boolean }, filter: Filter) => {
	const filters = [];

	filter.filterBucket = [];

	if (activeFilters.typeOfEvent) {
		filters.push(filter);
	}

	return filters;
};
