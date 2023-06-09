import { EventTypeEnum } from '$lib/types/content/metadata/event-types.enum';
import type { Event } from '$lib/types/event/event.interface';

export const overview: Event = {
	claimable: true,
	dateCreated: '06/05/2023',
	description: 'This is the first mock',
	eventId: '45363',
	extraMetadata: { key: 'string' },
	groups: ['TRY'],
	host: 'Twitter',
	image: 'string',
	name: 'Ignacio Debat',
	totalSupply: '2,306',
	transferrable: false,
	url: 'https://www.google.com.uy/',
	verifiers: [],

	// Added by Chino
	eventType: EventTypeEnum.Conference
};
