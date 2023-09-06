import { EVENT_TYPES } from '$lib/types/event/event-type.type';
import type { Event } from '$lib/types/event/event.interface';

export const overview: Event = {
	price: null,
	claimable: true,
	dateCreated: '06/05/2023',
	description: 'This is the first mock',
	eventId: '45363',
	extraMetadata: { key: 'string' },
	groups: ['TRY'],
	host: 'Twitter',
	eventImage:
		'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',
	eventLogo:
		'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',
	name: 'Ignacio Debat',
	totalSupply: '2,306',
	transferrable: false,
	url: 'https://www.google.com.uy/',
	verifiers: [{ dateStart: '06/05/2023', dateEnding: '06/20/2023' }],

	// Added by Chino
	eventType: EVENT_TYPES[1]
};
