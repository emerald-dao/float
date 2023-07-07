<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import { POWER_UPS, type PowerUpGeneratorData } from '../../../5-PowerUps/powerUps';
	import PowerUpReviewCard from '../atoms/PowerUpReviewCard.svelte';

	const paymentPowerUp = POWER_UPS.find(
		(powerUp) => powerUp.type === 'timelock'
	) as PowerUpGeneratorData<'timelock'>;

	const powerUpData = $eventGeneratorData.powerups.timelock;
</script>

<PowerUpReviewCard name={paymentPowerUp.name} icon={paymentPowerUp.icon}>
	<div class="row-2">
		{#if powerUpData.data.startDate}
			<div class="column-1">
				<span> Starte date </span>
				{powerUpData.data}
			</div>
		{/if}
		{#if powerUpData.data.endDate}
			<div class="column-1">
				<span> End date </span>
				{powerUpData.data}
			</div>
		{/if}
	</div>
</PowerUpReviewCard>
