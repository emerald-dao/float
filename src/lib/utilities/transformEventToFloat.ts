import type { Event } from '$lib/types/event/event.interface';
import type { FLOAT } from '$lib/types/float/float.interface';

function transformEventToFloat(event: Event): FLOAT {
	const float: FLOAT = {
		id: event.eventId,
		dateReceived: new Date().toLocaleString('default', {
			month: 'numeric',
			day: 'numeric',
			year: 'numeric'
		}),
		eventDescription: event.description,
		eventHost: event.host,
		eventId: event.eventId,
		eventImage: event.image,
		eventLogo: event.image,
		eventName: event.name,
		originalRecipient: 'John Doe',
		serial: '0001',
		totalSupply: event.totalSupply,
		transferrable: event.transferrable,
		eventType: event.eventType
	};
	console.log(float);
	return float;
}

export default transformEventToFloat;
