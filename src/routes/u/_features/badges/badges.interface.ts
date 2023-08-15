import type { FLOAT } from '$lib/types/float/float.interface';
import type { Event } from '$lib/types/event/event.interface';

export interface Badge {
	name: string;
	levels: Level[];
	rule: (data1: FLOAT[] | Event[] | number, data2?: number) => number;
}

export interface Level {
	name: string;
	image: string;
	description: string;
	goal: string;
}
