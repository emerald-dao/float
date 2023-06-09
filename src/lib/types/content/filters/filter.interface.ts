import type { EventTypeEnum } from '../metadata/event-types.enum';

export interface Filter {
	title: string;
	slug: 'type-of-event';
	filterElement: FilterElement[];
	filterBucket: FilterSlugs[];
}

interface FilterElement {
	icon: string;
	slug: FilterSlugs;
}

export type FilterSlugs = EventTypeEnum;
