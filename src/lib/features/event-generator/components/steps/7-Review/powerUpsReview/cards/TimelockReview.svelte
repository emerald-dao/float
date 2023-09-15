<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import type { TimelockStatus } from '$lib/features/event-status-management/types/verifiers-status.interface';
	import type { EventWithStatus } from '$lib/types/event/event.interface';
	import type { Timelock } from '$lib/types/event/verifiers.interface';
	import { unixTimestampToFormattedDate } from '$lib/utilities/dates/unixTimestampToFormattedDate';
	import { POWER_UPS, type PowerUpGeneratorData } from '../../../6-PowerUps/powerUps';
	import PowerUpReviewCard from '../atoms/PowerUpReviewCard.svelte';

	export let event: EventWithStatus | null = null;
	export let timelockStatus: TimelockStatus | null = null;

	const timelockPowerUp = POWER_UPS.find(
		(powerUp) => powerUp.type === 'timelock'
	) as PowerUpGeneratorData<'timelock'>;

	let powerUpData = {
		active: false,
		data: { dateStart: '', dateEnding: '' }
	};

	let dates = {
		dateStart: '',
		dateEnding: ''
	};

	if ($eventGeneratorData.powerups.timelock.active) {
		powerUpData = $eventGeneratorData.powerups.timelock;
	} else if (event) {
		event.verifiers.forEach((verifier) => {
			if (verifier.hasOwnProperty('dateStart')) {
				dates.dateStart = (verifier as Timelock).dateStart;
			}
			if ((verifier as Timelock).dateEnding) {
				dates.dateEnding = (verifier as Timelock).dateEnding;
			}
		});
	}

	$: message =
		timelockStatus?.status === 'expired'
			? 'Expired'
			: timelockStatus?.status === 'unlocked'
			? `${timelockStatus?.remainingTime} days left`
			: `Starts in ${timelockStatus?.remainingTime} days`;
</script>

<PowerUpReviewCard name={timelockPowerUp.name} icon={timelockPowerUp.icon}>
	<div class="row-7">
		{#if powerUpData.data.dateStart || dates.dateStart}
			<div class="column align-center">
				<span class="off small"> Start date </span>
				<span class="small">
					{#if powerUpData.data.dateStart}
						{unixTimestampToFormattedDate(powerUpData.data.dateStart)}
					{:else}
						{unixTimestampToFormattedDate(dates.dateStart)}
					{/if}
				</span>
			</div>
		{/if}
		{#if powerUpData.data.dateEnding || dates.dateEnding}
			<div class="column align-center">
				<span class="off small"> End date </span>
				<span class="small">
					{#if powerUpData.data.dateEnding}
						{unixTimestampToFormattedDate(powerUpData.data.dateEnding)}
					{:else}
						{unixTimestampToFormattedDate(dates.dateEnding)}
					{/if}
				</span>
			</div>
		{/if}
	</div>
	{#if timelockStatus !== null}
		<div class="bottom-wrapper">
			<div>
				<span class="xsmall">{message}</span>
			</div>
		</div>
	{/if}
</PowerUpReviewCard>

<style lang="scss">
	.row-7 {
		padding: var(--space-1) var(--space-4);
		span.off {
			color: var(--clr-text-off);
		}
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
