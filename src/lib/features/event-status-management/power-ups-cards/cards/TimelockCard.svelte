<script lang="ts">
	import {
		POWER_UPS,
		type PowerUpGeneratorData
	} from '$lib/features/event-generator/components/steps/6-PowerUps/powerUps';
	import type { TimelockStatus } from '$lib/features/event-status-management/types/verifiers-status.interface';
	import { unixTimestampToFormattedDate } from '$lib/utilities/dates/unixTimestampToFormattedDate';
	import { timelockToStatusObject } from '../../functions/helpers/timelockToStatusObject';
	import PowerUpReviewCard from '../atoms/PowerUpCard.svelte';

	export let startDate: string;
	export let endDate: string;

	let timelockStatus: TimelockStatus = timelockToStatusObject(startDate, endDate);

	const timelockPowerUp = POWER_UPS.find(
		(powerUp) => powerUp.type === 'timelock'
	) as PowerUpGeneratorData<'timelock'>;

	$: message =
		timelockStatus?.status === 'expired'
			? 'Expired'
			: timelockStatus?.status === 'unlocked'
			? `${timelockStatus?.remainingTime} days left`
			: `Starts in ${timelockStatus?.remainingTime} days`;
</script>

<PowerUpReviewCard name={timelockPowerUp.name} icon={timelockPowerUp.icon} let:PowerUpCard>
	<PowerUpCard.Content>
		<div class="main-wrapper">
			{#if startDate}
				<div class="date-wrapper">
					<span class="date-title"> Start date </span>
					<PowerUpCard.Details>
						{unixTimestampToFormattedDate(startDate)}
					</PowerUpCard.Details>
				</div>
			{/if}
			{#if endDate}
				<div class="date-wrapper">
					<span class="date-title"> End date </span>
					<PowerUpCard.Details>
						{unixTimestampToFormattedDate(endDate)}
					</PowerUpCard.Details>
				</div>
			{/if}
		</div>
	</PowerUpCard.Content>
	{#if timelockStatus !== null}
		<PowerUpCard.State status="inactive" {message} />
	{/if}
</PowerUpReviewCard>

<style lang="scss">
	.main-wrapper {
		display: flex;
		flex-direction: row;
		gap: 1em;

		.date-wrapper {
			display: flex;
			flex-direction: column;
			align-items: flex-start;
			gap: 0.25em;

			.date-title {
				font-size: 0.6em;
				line-height: 1;
				color: var(--clr-text-off);
				opacity: 0.8;
			}
		}
	}
</style>
