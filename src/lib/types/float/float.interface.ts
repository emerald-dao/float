import type { EventType } from '../event/event-type.type';
import type { MedalType } from '../event/medal-types.type';

export interface FLOAT {
	id: string;
	dateReceived: string;
	eventDescription: string;
	eventHost: string;
	eventId: string;
	backImage: string | File;
	eventImage: string | File;
	eventName: string;
	originalRecipient: string;
	serial: string;
	totalSupply: string | null;
	transferrable: boolean;
	eventType: EventType;
	extraMetadata: { [key: string]: string | null; medalType: MedalType | null };
	visibilityMode?: 'certificate' | 'picture';
}
