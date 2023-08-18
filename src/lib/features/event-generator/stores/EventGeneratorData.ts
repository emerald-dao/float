import { writable, type Writable, derived, type Readable } from 'svelte/store';
import type { EventGeneratorData } from '../types/event-generator-data.interface';
import type { FLOAT } from '$lib/types/float/float.interface';

export const eventGeneratorData: Writable<EventGeneratorData> = writable({
	description: '',
	eventId: '',
	host: '',
	logo: [],
	image: [],
	name: '',
	url: '',
	totalSupply: '',
	transferrable: false,
	claimable: false,
	eventType: 'conference',
	powerups: {
		payment: {
			active: false,
			data: 0
		},
		timelock: {
			active: false,
			data: {
				dateStart: '',
				dateEnding: ''
			}
		},
		secretCode: {
			active: false,
			data: ''
		},
		limited: {
			active: false,
			data: 0
		},
		minimumBalance: {
			active: false,
			data: 0
		}
	}
});

export const generatedNft: Readable<FLOAT> = derived(eventGeneratorData, ($eventGeneratorData) => ({
	eventDescription: $eventGeneratorData.description,
	eventHost: $eventGeneratorData.host,
	eventId: $eventGeneratorData.eventId,
	eventLogo: $eventGeneratorData.logo[0] as File,
	eventImage: $eventGeneratorData.image[0] as File,
	eventName: $eventGeneratorData.name,
	totalSupply: $eventGeneratorData.totalSupply,
	transferrable: $eventGeneratorData.transferrable,
	eventType: $eventGeneratorData.eventType,
	originalRecipient: 'jacob.find',
	id: '00001',
	serial: '',
	dateReceived: ''
}));
