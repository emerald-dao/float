import type { EventType } from '$lib/types/event/event-type.type';

export interface Filter {
	title: string;
	slug: 'type-of-event';
	filterElement: FilterElement[];
	filterBucket: FilterSlugs[];
}

interface FilterElement {
	icon: string;
	slug: FilterSlugs;
	text: string;
}

export type FilterSlugs = EventType;
