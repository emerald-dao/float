import type { Filter } from '$lib/types/content/filters/filter.interface';
import { EVENT_TYPE_DETAILS, EVENT_TYPES } from '$lib/types/event/even-type.type';

let typeOfEventFilter: Filter = {
	title: 'Type of event',
	slug: 'type-of-event',
	filterElement: [
		{
			icon: 'icon',
			slug: EVENT_TYPES[0],
			text: EVENT_TYPE_DETAILS[0].eventTypeName
		},
		{
			icon: 'icon',
			slug: EVENT_TYPES[1],
			text: EVENT_TYPE_DETAILS[1].eventTypeName
		},
		{
			icon: 'icon',
			slug: EVENT_TYPES[2],
			text: EVENT_TYPE_DETAILS[2].eventTypeName
		},
		{
			icon: 'icon',
			slug: EVENT_TYPES[3],
			text: EVENT_TYPE_DETAILS[3].eventTypeName
		},
		{
			icon: 'icon',
			slug: EVENT_TYPES[4],
			text: EVENT_TYPE_DETAILS[4].eventTypeName
		},
		{
			icon: 'icon',
			slug: EVENT_TYPES[5],
			text: EVENT_TYPE_DETAILS[5].eventTypeName
		},
		{
			icon: 'icon',
			slug: EVENT_TYPES[6],
			text: EVENT_TYPE_DETAILS[6].eventTypeName
		},
		{
			icon: 'icon',
			slug: EVENT_TYPES[7],
			text: EVENT_TYPE_DETAILS[7].eventTypeName
		},
		{
			icon: 'icon',
			slug: EVENT_TYPES[8],
			text: EVENT_TYPE_DETAILS[8].eventTypeName
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
