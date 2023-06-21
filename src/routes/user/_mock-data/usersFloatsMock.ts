import { EVENT_TYPES } from '$lib/types/event/even-type.type';
import type { FLOAT } from '$lib/types/float/float.interface';

const usersFloatsMock: FLOAT[] = [
	{
		id: '1',
		dateReceived: '06/05/2023',
		eventDescription: 'This is the first mock',
		eventHost: 'Twitter',
		eventId: '45363',
		eventImage: 'string',
		eventLogo: 'string',
		eventName: 'Ignacio Debat',
		originalRecipient: 'string',
		serial: 'string',
		totalSupply: '2,306',
		transferrable: false,
		eventType: EVENT_TYPES[0]
	},
	{
		id: '2',
		dateReceived: '06/05/2023',
		eventDescription: 'This is the first mock',
		eventHost: 'Twitter',
		eventId: '45363',
		eventImage: 'string',
		eventLogo: 'string',
		eventName: 'Ignacio Debat',
		originalRecipient: 'string',
		serial: 'string',
		totalSupply: '2,306',
		transferrable: false,
		eventType: EVENT_TYPES[1]
	},
	{
		id: '3',

		dateReceived: '06/05/2023',
		eventDescription: 'This is the first mock',
		eventHost: 'Twitter',
		eventId: '45363',
		eventImage: 'string',
		eventLogo: 'string',
		eventName: 'Ignacio Debat',
		originalRecipient: 'string',
		serial: 'string',
		totalSupply: '2,306',
		transferrable: false,
		eventType: EVENT_TYPES[2]
	}
];

export default usersFloatsMock;
