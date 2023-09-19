// FLOATs interfaces and types
import type {
	LimitedStatus,
	TimelockStatus
} from '$lib/features/event-status-management/types/verifiers-status.interface';
import type { EventType } from './event-type.type';
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
	eventLogo: string;
	name: string;
	price: string | null;
	totalSupply: string;
	transferrable: boolean;
	url: string;
	verifiers: EventVerifiers;
	eventType: EventType;
	visibilityMode?: 'certificate' | 'picture';
}

export interface EventVerifiers {
	timelock?: Timelock;
	secret?: Secret;
	limited?: Limited;
	minimumBalance?: MinimumBalance;
}

export interface EventWithStatus extends Event {
	status: {
		verifiersStatus: {
			timelockStatus: TimelockStatus;
			limitedStatus: LimitedStatus;
		};
		generalStatus: EventGeneralStatus;
	};
}

export type EventGeneralStatus = 'available' | 'soldout' | 'paused' | 'expired' | 'locked';
