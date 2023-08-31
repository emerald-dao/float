import type { FLOAT } from '$lib/types/float/float.interface';
import type { Event } from '$lib/types/event/event.interface';
import type { EventType } from '$lib/types/event/event-type.type';

export interface Badge {
	name: string;
	levels: Level[];
	rule: (data: FLOAT[] | Event[], eventType?: EventType) => number;
}

export interface Level {
	name: string;
	image: string;
	description: string;
	goal: string;
}
