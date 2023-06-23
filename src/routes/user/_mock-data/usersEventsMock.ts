import { EVENT_TYPES } from '$lib/types/event/even-type.type';
import type { Event } from '$lib/types/event/event.interface';

const usersEventsMock: Event[] = [
	{
		price: '600',
		claimable: true,
		dateCreated: '2021-08-01T00:00:00.000Z',
		description: 'This is a description',
		eventId: '0x1234567890',
		extraMetadata: {
			foo: 'bar'
		},
		groups: ['0x1234567890', '0x1234567890'],
		host: '0x1234567890',
		image: 'https://i.pravatar.cc/300',
		name: 'Event Name',
		totalSupply: '10000',
		transferrable: true,
		url: 'https://google.com',
		verifiers: [],
		eventType: EVENT_TYPES[0]
	}
];

export default usersEventsMock;
