<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import { Currency } from '@emerald-dao/component-library';
	import { POWER_UPS, type PowerUpGeneratorData } from '../../../6-PowerUps/powerUps';
	import PowerUpReviewCard from '../atoms/PowerUpReviewCard.svelte';
	import type { EventWithStatus } from '$lib/types/event/event.interface';

	export let event: EventWithStatus | null = null;

	const paymentPowerUp = POWER_UPS.find(
		(powerUp) => powerUp.type === 'payment'
	) as PowerUpGeneratorData<'payment'>;

	let powerUpData = {
		active: false,
		data: 0
	};

	let payment: string;

	if ($eventGeneratorData.powerups.payment.active) {
		powerUpData = $eventGeneratorData.powerups.payment;
	} else if (event?.price) {
		payment = event.price;
	}
</script>

<PowerUpReviewCard name={paymentPowerUp.name} icon={paymentPowerUp.icon}>
	<div class="column align-center">
		{#if powerUpData.data}
			<Currency amount={powerUpData.data} currency="FLOW" fontSize="var(--font-size-1)" />
		{:else if event?.price}
			<Currency amount={payment} currency="FLOW" fontSize="var(--font-size-1)" />
		{/if}
	</div>
</PowerUpReviewCard>

<style lang="scss">
	div {
		padding: var(--space-1) var(--space-4);
	}
</style>
