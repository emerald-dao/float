import type {
	PowerUpData,
	PowerUps
} from '$lib/features/event-generator/types/event-generator-data.interface';
import type { SvelteComponent } from 'svelte';
import PaymentPowerUp from './powerUpsConfigs/PaymentPowerUp.svelte';
import TimeLimitPowerUp from './powerUpsConfigs/TimeLimitPowerUp.svelte';
import SecretCodePowerUp from './powerUpsConfigs/SecretCodePowerUp.svelte';
import MinimumBalancePowerUp from './powerUpsConfigs/MinimumBalancePowerUp.svelte';
import LimitedPowerUp from './powerUpsConfigs/LimitedPowerUp.svelte';

export interface PowerUp {
	type: PowerUps;
	name: string;
	data: PowerUpData<typeof this.type>; // improve this
	icon: string;
	description: string;
	component: typeof SvelteComponent;
}

const POWER_UPS: PowerUp[] = [
	{
		type: 'payment',
		name: 'Payment',
		icon: 'tabler:cash',
		description: 'This FLOAT costs $FLOW to claim. Suitable for things like tickets.',
		data: 'fef', // how can i handle this?
		component: PaymentPowerUp
	},
	{
		type: 'time-limit',
		name: 'Time Limit',
		icon: 'tabler:clock',
		description: 'This FLOAT will only be available for a limited time.',
		data: 'fef', // how can i handle this?
		component: TimeLimitPowerUp
	},
	{
		type: 'secret-code',
		name: 'Secret Code',
		icon: 'tabler:key',
		description: 'This FLOAT can only be claimed by entering a secret code.',
		data: 'fef', // how can i handle this?
		component: SecretCodePowerUp
	},
	{
		type: 'limited',
		name: 'Limit Supply',
		icon: 'tabler:chart-bubble',
		description: 'This FLOAT can only be claimed a limited number of times.',
		data: 'fef', // how can i handle this?
		component: LimitedPowerUp
	},
	{
		type: 'minimum-balance',
		name: 'Minimum Balance',
		icon: 'tabler:coin',
		description: 'This FLOAT can only be claimed by users with a minimum $FLOW balance.',
		data: 'fef', // how can i handle this?
		component: MinimumBalancePowerUp
	}
];

export default POWER_UPS;
