import type { PowerUpType } from '$lib/features/event-generator/types/event-generator-data.interface';

export interface Timelock {
	dateStart: string;
	dateEnding: string;
	type: 'timelock';
}

export interface Limited {
	capacity: string;
	type: 'limited';
}

export interface Secret {
	secret: string;
	type: 'secret';
}

export interface MinimumBalance {
	amount: string;
	type: 'minimumBalance';
}

export interface RequireEmail {
	type: 'requireEmail'
}

export type VerifierData<T extends PowerUpType> = T extends 'timelock'
	? Timelock
	: T extends 'secret'
	? Secret
	: T extends 'limited'
	? Limited
	: T extends 'minimumBalance'
	? MinimumBalance
	: T extends 'requireEmail'
	? RequireEmail
	: never;
