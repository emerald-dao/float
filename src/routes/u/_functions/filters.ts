import type { Filter } from '$lib/types/content/filters/filter.interface';
import { EVENT_TYPE_DETAILS, EVENT_TYPES } from '$lib/types/event/even-type.type';

let typeOfEventFilter: Filter = {
	title: 'Type of event',
	slug: 'type-of-event',
	filterElement: EVENT_TYPES.map((eventType) => {
		return {
			icon: 'icon',
			slug: eventType,
			text: EVENT_TYPE_DETAILS[eventType].eventTypeName
		};
	}),
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
