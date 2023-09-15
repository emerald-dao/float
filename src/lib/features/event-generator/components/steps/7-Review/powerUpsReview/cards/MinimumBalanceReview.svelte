<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import { Currency } from '@emerald-dao/component-library';
	import { POWER_UPS, type PowerUpGeneratorData } from '../../../6-PowerUps/powerUps';
	import PowerUpReviewCard from '../atoms/PowerUpReviewCard.svelte';
	import type { EventWithStatus } from '$lib/types/event/event.interface';
	import type { MinimumBalance } from '$lib/types/event/verifiers.interface';

	export let event: EventWithStatus | null = null;

	const minimumBalance = POWER_UPS.find(
		(powerUp) => powerUp.type === 'minimumBalance'
	) as PowerUpGeneratorData<'minimumBalance'>;

	let powerUpData = {
		active: false,
		data: 0
	};

	let amount: string;

	if ($eventGeneratorData.powerups.minimumBalance.active) {
		powerUpData = $eventGeneratorData.powerups.minimumBalance;
	} else if (event) {
		event.verifiers.forEach((verifier) => {
			if (verifier.hasOwnProperty('amount')) {
				amount = (verifier as MinimumBalance).amount;
			}
		});
	}
</script>

<PowerUpReviewCard name={minimumBalance.name} icon={minimumBalance.icon}>
	<div class="column align-center">
		{#if powerUpData.data}
			<Currency amount={powerUpData.data} currency="FLOW" fontSize="var(--font-size-1)" />
		{:else if amount}
			<Currency {amount} currency="FLOW" fontSize="var(--font-size-1)" />
		{/if}
	</div>
</PowerUpReviewCard>

<style lang="scss">
	div {
		padding: var(--space-1) var(--space-4);
	}
</style>
