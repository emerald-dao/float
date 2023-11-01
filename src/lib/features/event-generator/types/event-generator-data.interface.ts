import type { CertificateType, EventType } from '$lib/types/event/event-type.type';

export type EventGeneratorData = EventGeneratorDataWithMedal | EventGeneratorDataWithNoMedal;

export interface BaseEventGeneratorData {
	name: string;
	eventId: string;
	eventType: EventType;
	certificateType: CertificateType;
	description: string;
	host: string;
	url: string;
	logo: [File] | [];
	image: [File] | [];
	ticketImage:
	| File
	| {
		gold: File;
		silver: File;
		bronze: File;
		participation: File;
	}
	| null;
	totalSupply: string;
	transferrable: boolean;
	multipleClaim: boolean;
	claimable: boolean;
	visibilityMode: 'certificate' | 'picture';
	powerups: EventGeneratorPowerUps;
}

export interface EventGeneratorDataWithMedal extends BaseEventGeneratorData {
	certificateType: 'medal';
	ticketImage: {
		gold: File;
		silver: File;
		bronze: File;
		participation: File;
	};
}

export interface EventGeneratorDataWithNoMedal extends BaseEventGeneratorData {
	certificateType: 'certificate' | 'ticket';
	ticketImage: File | null;
}

export type EventGeneratorPowerUps = {
	[key in PowerUpType]: {
		active: boolean;
		data: PowerUpData<key>;
	};
};

export const POWER_UPS_TYPES = [
	'payment',
	'timelock',
	'secret',
	'limited',
	'minimumBalance',
	'requireEmail'
] as const;

export type PowerUpType = (typeof POWER_UPS_TYPES)[number];

type PaymentPowerUpData = number;
type TimeLockPowerUpData = {
	dateStart: string; // unix timestamp
	dateEnding: string; // unix timestamp
};
type SecretCodePowerUpData = string;
type LimitedPowerUpData = number;
type MinimumBalance = number;
type RequireEmail = boolean;

export type PowerUpData<T extends PowerUpType> = T extends 'payment'
	? PaymentPowerUpData
	: T extends 'timelock'
	? TimeLockPowerUpData
	: T extends 'secret'
	? SecretCodePowerUpData
	: T extends 'limited'
	? LimitedPowerUpData
	: T extends 'minimumBalance'
	? MinimumBalance
	: T extends 'requireEmail'
	? RequireEmail
	: never;
