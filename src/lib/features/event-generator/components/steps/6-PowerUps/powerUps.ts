import type { PowerUpType } from '$lib/features/event-generator/types/event-generator-data.interface';
import type { SvelteComponent } from 'svelte';
import PaymentPowerUp from './powerUpsConfigs/Payment/PaymentPowerUp.svelte';
import TimeLimitPowerUp from './powerUpsConfigs/TimeLimit/TimeLimitPowerUp.svelte';
import SecretCodePowerUp from './powerUpsConfigs/SecretCode/SecretCodePowerUp.svelte';
import MinimumBalancePowerUp from './powerUpsConfigs/MinimumBalance/MinimumBalancePowerUp.svelte';
import LimitedPowerUp from './powerUpsConfigs/Limited/LimitedPowerUp.svelte';
import { writable } from 'svelte/store';

export interface PowerUpGeneratorData<T extends PowerUpType> {
	type: T;
	name: string;
	icon: string;
	description: string;
	component: typeof SvelteComponent;
}

export const POWER_UPS: PowerUpGeneratorData<PowerUpType>[] = [
	{
		type: 'payment',
		name: 'Payment',
		icon: 'tabler:cash',
		description: 'This FLOAT costs $FLOW to claim. Suitable for things like tickets.',
		component: PaymentPowerUp
	},
	{
		type: 'timelock',
		name: 'Timelock',
		icon: 'tabler:clock',
		description: 'This FLOAT will only be available for a limited time.',
		component: TimeLimitPowerUp
	},
	{
		type: 'secretCode',
		name: 'Secret Code',
		icon: 'tabler:key',
		description: 'This FLOAT can only be claimed by entering a secret code.',
		component: SecretCodePowerUp
	},
	{
		type: 'limited',
		name: 'Supply',
		icon: 'tabler:chart-bubble',
		description: 'This FLOAT can only be claimed a limited number of times.',
		component: LimitedPowerUp
	},
	{
		type: 'minimumBalance',
		name: 'Min. Balance',
		icon: 'tabler:coin',
		description: 'This FLOAT can only be claimed by users with a minimum $FLOW balance.',
		component: MinimumBalancePowerUp
	}
];

const POWER_UPS_VALIDATION_DATA = POWER_UPS.reduce((acc, powerUp) => {
	acc[powerUp.type] = false;
	return acc;
}, {} as { [key in PowerUpType]: boolean });

export const powerUpsValidations = writable(POWER_UPS_VALIDATION_DATA);
