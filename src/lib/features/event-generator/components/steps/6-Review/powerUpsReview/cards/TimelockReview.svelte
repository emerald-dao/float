<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import { unixTimestampToFormattedDate } from '$lib/utilities/dates/unixTimestampToFormattedDate';
	import { POWER_UPS, type PowerUpGeneratorData } from '../../../5-PowerUps/powerUps';
	import PowerUpReviewCard from '../atoms/PowerUpReviewCard.svelte';

	const paymentPowerUp = POWER_UPS.find(
		(powerUp) => powerUp.type === 'timelock'
	) as PowerUpGeneratorData<'timelock'>;

	const powerUpData = $eventGeneratorData.powerups.timelock;

	$: formattedStartDate = unixTimestampToFormattedDate(powerUpData.data.startDate);
</script>

<PowerUpReviewCard name={paymentPowerUp.name} icon={paymentPowerUp.icon}>
	<div class="row-7">
		{#if powerUpData.data.startDate}
			<div class="column">
				<span class="small"> Start date </span>
				{formattedStartDate}
			</div>
		{/if}
		{#if powerUpData.data.endDate}
			<div class="column">
				<span class="small"> End date </span>
				{unixTimestampToFormattedDate(powerUpData.data.endDate)}
			</div>
		{/if}
	</div>
</PowerUpReviewCard>

<style lang="scss">
	span.small {
		color: var(--clr-text-off);
	}
</style>
