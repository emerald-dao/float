import type { EventType } from '$lib/types/event/even-type.type';

export interface EventGeneratorData {
	name: string;
	eventId: string;
	eventType: EventType;
	description: string;
	host: string;
	url: string;
	logo: [File] | [];
	image: [File] | [];
	totalSupply: string;
	transferrable: boolean;
	claimable: boolean;
	powerups: {
		[key in PowerUpType]: {
			active: boolean;
			data: PowerUpData<key>;
		};
	};
}

export const POWER_UPS_TYPES = [
	'payment',
	'timelock',
	'secretCode',
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
	: T extends 'secretCode'
	? SecretCodePowerUpData
	: T extends 'limited'
	? LimitedPowerUpData
	: T extends 'minimumBalance'
	? MinimumBalance
	: never;
