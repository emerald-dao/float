<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import type { LimitedStatus } from '$lib/features/event-status-management/types/verifiers-status.interface';
	import type { EventWithStatus } from '$lib/types/event/event.interface';
	import type { Limited } from '$lib/types/event/verifiers.interface';
	import { POWER_UPS, type PowerUpGeneratorData } from '../../../6-PowerUps/powerUps';
	import PowerUpReviewCard from '../atoms/PowerUpReviewCard.svelte';

	export let event: EventWithStatus | null = null;
	export let limitedStatus: LimitedStatus | null = null;

	const limitedPowerUp = POWER_UPS.find(
		(powerUp) => powerUp.type === 'limited'
	) as PowerUpGeneratorData<'limited'>;

	let powerUpData = {
		active: false,
		data: 0
	};

	let capacity: string;

	if ($eventGeneratorData.powerups.limited.active) {
		powerUpData = $eventGeneratorData.powerups.limited;
	} else if (event) {
		event.verifiers.forEach((verifier) => {
			if (verifier.hasOwnProperty('capacity')) {
				capacity = (verifier as Limited).capacity;
			}
		});
	}

	$: message =
		limitedStatus?.status === 'soldout' ? 'Sold out' : `${limitedStatus?.remainingFloats} left`;
</script>

<PowerUpReviewCard name={limitedPowerUp.name} icon={limitedPowerUp.icon}>
	<div class="column align-center">
		<span class="small">
			{#if powerUpData.data}
				{powerUpData.data} NFTs
			{:else}
				{capacity} NFTs
			{/if}
		</span>
	</div>
	{#if limitedStatus !== null}
		<div class="bottom-wrapper">
			<div>
				<span class="xsmall">{message}</span>
			</div>
		</div>
	{/if}
</PowerUpReviewCard>

<style lang="scss">
	.column {
		padding: var(--space-1) var(--space-4);
	}

	.bottom-wrapper {
		border-top: 1px dashed var(--clr-border-primary);
		padding: 0 var(--space-4);

		div {
			display: flex;
			justify-content: center;
			align-items: center;
			text-align: center;
			padding: var(--space-1) var(--space-4);
		}
	}
</style>
