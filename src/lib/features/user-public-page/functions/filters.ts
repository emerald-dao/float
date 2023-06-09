import type { Filter } from '$lib/types/content/filters/filter.interface';
import { EventTypeEnum } from '$lib/types/content/metadata/event-types.enum';

export const typeOfEventFilter: Filter = {
	title: 'Type of event',
	slug: 'type-of-event',
	filterElement: [
		{
			icon: 'icon',
			slug: EventTypeEnum.BirthdayParty
		},
		{
			icon: 'icon',
			slug: EventTypeEnum.Conference
		},
		{
			icon: 'icon',
			slug: EventTypeEnum.DiscordAMA
		},
		{
			icon: 'icon',
			slug: EventTypeEnum.LiveStreaming
		},
		{
			icon: 'icon',
			slug: EventTypeEnum.Online
		},
		{
			icon: 'icon',
			slug: EventTypeEnum.OnsiteCourse
		},
		{
			icon: 'icon',
			slug: EventTypeEnum.ProductLunch
		},
		{
			icon: 'icon',
			slug: EventTypeEnum.Sport
		},
		{
			icon: 'icon',
			slug: EventTypeEnum.Twitter
		},
		{
			icon: 'icon',
			slug: EventTypeEnum.Webinar
		},
		{
			icon: 'icon',
			slug: EventTypeEnum.Workshop
		},
		{
			icon: 'icon',
			slug: EventTypeEnum.YouTube
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
