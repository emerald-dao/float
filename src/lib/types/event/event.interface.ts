// FLOATs interfaces and types
import type {
	LimitedStatus,
	TimelockStatus
} from '$lib/features/event-status-management/types/verifiers-status.interface';
import type { EventType } from './event-type.type';
import type { VerifierData } from './verifiers.interface';
import type { PowerUpType } from '../../features/event-generator/types/event-generator-data.interface';

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
	multipleClaim: boolean;
	url: string;
	verifiers: EventVerifiers;
	eventType: EventType;
	visibilityMode?: 'certificate' | 'picture';
}

export type EventVerifiers = {
	[key in PowerUpType]?: VerifierData<key>;
};

export interface EventWithStatus extends Event {
	status: {
		verifiersStatus: {
			timelockStatus: TimelockStatus;
			limitedStatus: LimitedStatus;
		};
		generalStatus: EventGeneralStatus;
	};
}

export type EventGeneralStatus = 'available' | 'soldout' | 'expired' | 'locked';
