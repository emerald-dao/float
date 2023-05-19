import { writable, type Writable } from 'svelte/store';
import type { EventGeneratorData } from '../types/event-generator-data.interface';

export const emptyEventGeneratorData: EventGeneratorData = {
	id: 'unique-id'
};
export const eventGeneratorData: Writable<EventGeneratorData> = writable(emptyEventGeneratorData);
