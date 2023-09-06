import type { Event } from '$lib/types/event/event.interface';
import type { FLOAT } from '$lib/types/float/float.interface';
import { unixTimestampToFormattedDate } from './dates/unixTimestampToFormattedDate';

function transformEventToFloat(event: Event): FLOAT {
	const float: FLOAT = {
		id: event.eventId,
		dateReceived: `${Date.now() / 1000}`,
		eventDescription: event.description,
		eventHost: event.host,
		eventId: event.eventId,
		eventImage: event.image,
		eventLogo: event.eventLogo,
		eventName: event.name,
		originalRecipient: '0x99bd48c8036e2876',
		serial: '1',
		totalSupply: event.totalSupply,
		transferrable: event.transferrable,
		eventType: event.eventType
	};

	return float;
}

export default transformEventToFloat;
