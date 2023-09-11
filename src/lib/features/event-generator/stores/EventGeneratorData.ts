import { writable, type Writable, derived, type Readable, get } from 'svelte/store';
import type { EventGeneratorData } from '../types/event-generator-data.interface';
import type { FLOAT } from '$lib/types/float/float.interface';
import { user } from '$lib/stores/flow/FlowStore';
import { EVENT_TYPE_DETAILS } from '$lib/types/event/event-type.type';

export const eventGeneratorData: Writable<EventGeneratorData> = writable({
	description: '',
	eventId: '',
	host: get(user).addr ?? '',
	logo: [],
	image: [],
	ticketImage: null,
	name: '',
	url: '',
	totalSupply: '',
	transferrable: false,
	claimable: false,
	eventType: 'conference',
	certificateType: 'ticket',
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
	eventId: '123456789',
	eventLogo: $eventGeneratorData.logo[0] as File,
	eventImage: $eventGeneratorData.image[0] as File,
	eventName: $eventGeneratorData.name,
	totalSupply: $eventGeneratorData.totalSupply,
	transferrable: $eventGeneratorData.transferrable,
	eventType: $eventGeneratorData.eventType,
	originalRecipient: '0x99bd48c8036e2876',
	id: '00001',
	serial: '1',
	dateReceived: `${Date.now() / 1000}`,
	extraMetadata: {
		medalType:
			EVENT_TYPE_DETAILS[$eventGeneratorData.eventType].certificateType === 'medal'
				? ('gold' as const)
				: null
	}
}));
