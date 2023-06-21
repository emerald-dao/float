import { EventTypeEnum } from '$lib/types/content/metadata/event-types.enum';
import type { Event } from '$lib/types/event/event.interface';

const eventsMock: Event[] = [
	{
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

		// Added by Chino
		eventType: EventTypeEnum.Conference
	},
	{
		claimable: true,
		dateCreated: '06/05/2023',
		description: 'This is the second mock',
		eventId: '34',
		extraMetadata: { key: 'string' },
		groups: ['TRY'],
		host: 'Twitter',
		image:
			'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',
		name: 'SECOND EVENT',
		totalSupply: '2,306',
		transferrable: false,
		url: 'https://www.google.com.uy/',
		verifiers: [{ dateStart: '06/05/2023', dateEnding: '06/20/2023' }],

		// Added by Chino
		eventType: EventTypeEnum.Workshop
	},
	{
		claimable: true,
		dateCreated: '06/05/2023',
		description: 'This is the third mock',
		eventId: '12',
		extraMetadata: { key: 'string' },
		groups: ['TRY'],
		host: 'Twitter',
		image:
			'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',
		name: 'THIRD EVENT',
		totalSupply: '2,306',
		transferrable: false,
		url: 'https://www.google.com.uy/',
		verifiers: [{ dateStart: '06/05/2023', dateEnding: '06/20/2023' }],

		// Added by Chino
		eventType: EventTypeEnum.Online
	}
];

export default eventsMock;
