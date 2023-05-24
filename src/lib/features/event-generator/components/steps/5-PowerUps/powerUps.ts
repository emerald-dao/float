import type {
	PowerUpData,
	PowerUps
} from '$lib/features/event-generator/types/event-generator-data.interface';
import type { SvelteComponent } from 'svelte';
import PaymentPowerUp from './powerUpsConfigs/PaymentPowerUp.svelte';
import TimeLimitPowerUp from './powerUpsConfigs/TimeLimitPowerUp.svelte';

interface PowerUp {
	type: PowerUps;
	name: string;
	data: PowerUpData<typeof this.type>; // improve this
	description: string;
	component: typeof SvelteComponent;
}

const POWER_UPS: PowerUp[] = [
	{
		type: 'payment',
		name: 'Payment',
		description: 'This FLOAT costs $FLOW to claim. Suitable for things like tickets.',
		data: 'fef', // how can i handle this?
		component: PaymentPowerUp
	},
	{
		type: 'time-limit',
		name: 'Time Limit',
		description: 'This FLOAT will only be available for a limited time.',
		data: 'fef', // how can i handle this?
		component: TimeLimitPowerUp
	}
];

export default POWER_UPS;
