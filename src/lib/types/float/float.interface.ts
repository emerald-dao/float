import type { EventType } from '../event/even-type.type';

export interface FLOAT {
	id: string;
	dateReceived: string;
	eventDescription: string;
	eventHost: string;
	eventId: string;
	eventImage: string | File;
	eventLogo: string | File;
	eventName: string;
	originalRecipient: string;
	serial: string;
	totalSupply: string | null;
	transferrable: boolean;
	// needed for the UI
	eventType: EventType;
}
