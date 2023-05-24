import type { EventType } from '$lib/types/event/even-type.type';

export interface EventGeneratorData {
	name: string;
	eventId: string;
	eventType: EventType;
	description: string;
	host: string;
	image: [File];
	totalSupply: string;
	transferrable: boolean;
	claimable: boolean;
	powerups: {
		[key in PowerUps]: PowerUpData<key>;
	};
}

export const POWER_UPS = ['payment', 'timelock', 'secretCode', 'limited', 'minimumBalance'];

export type PowerUps = (typeof POWER_UPS)[number];

type PaymentPowerUpData = number;
type TimeLockPowerUpData = string;
type SecretCodePowerUpData = string;
type MinimumBalance = string;

export type PowerUpData<T extends PowerUps> = T extends 'payment'
	? PaymentPowerUpData
	: T extends 'timelock'
	? TimeLockPowerUpData
	: T extends 'secretCode'
	? SecretCodePowerUpData
	: T extends 'minimumBalance'
	? MinimumBalance
	: never;
