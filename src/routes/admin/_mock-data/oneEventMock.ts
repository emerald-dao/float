import { EVENT_TYPES } from '$lib/types/event/even-type.type';
import type { Event } from '$lib/types/event/event.interface';

const eventMock: Event = {
	price: '300',
	claimable: true,
	dateCreated: '06/05/2023',
	description: 'This is the first mock',
	eventId: '56',
	extraMetadata: { key: 'string' },
	groups: ['TRY'],
	host: 'Twitter',
	image:
		'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',
	name: 'FIRST EVENT',
	totalSupply: '2,306',
	transferrable: false,
	url: 'https://www.google.com.uy/',
	verifiers: [],
	eventType: EVENT_TYPES[0]
};

export default eventMock;
