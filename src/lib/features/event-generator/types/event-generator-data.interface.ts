import type { CertificateType, EventType } from '$lib/types/event/event-type.type';

export interface EventGeneratorData {
	name: string;
	eventId: string;
	eventType: EventType;
	certificateType: CertificateType;
	description: string;
	host: string;
	url: string;
	logo: [File] | [];
	image: [File] | [];
	ticketImage: File | null;
	totalSupply: string;
	transferrable: boolean;
	claimable: boolean;
	visibilityMode: 'certificate' | 'picture';
	powerups: EventGeneratorPowerUps;
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
	'minimumBalance'
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
	: never;
