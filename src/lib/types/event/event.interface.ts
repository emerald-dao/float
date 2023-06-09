// FLOATs interfaces and types

import type { EventTypeEnum } from '../content/metadata/event-types.enum';
import type { Limited, MinimumBalance, Secret, Timelock } from './verifiers.interface';

export interface Event {
	claimable: boolean;
	dateCreated: string;
	description: string;
	eventId: string;
	extraMetadata: { [key: string]: any };
	groups: string[];
	host: string;
	image: string;
	name: string;
	totalSupply: string;
	transferrable: boolean;
	url: string;
	verifiers: EventVerifier[];

	// Added by Chino
	eventType: EventTypeEnum;
}

type EventVerifier = Timelock | Secret | Limited | MinimumBalance;
