// FLOATs interfaces and types
import type { EventType } from './even-type.type';
import type { Limited, MinimumBalance, Secret, Timelock } from './verifiers.interface';

export interface Event {
	claimable: boolean;
	dateCreated: string;
	description: string;
	eventId: string;
	extraMetadata: { [key: string]: any };
	groups: string[];
	host: string;
	eventImage: string;
	eventLogo: string;
	name: string;
	price: string | null;
	totalSupply: string;
	transferrable: boolean;
	url: string;
	verifiers: EventVerifier[];
	eventType: EventType;
}

export type EventVerifier = Timelock | Secret | Limited | MinimumBalance;
