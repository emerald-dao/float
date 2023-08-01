<script lang="ts">
	import FloatTicket from '$lib/components/floats/FloatTicket.svelte';
	import Icon from '@iconify/svelte';
	import ClaimTicketCard from './atoms/ClaimTicketCard.svelte';
	import transformEventToFloat from '$lib/utilities/transformEventToFloat';
	import { datesToStatusObject } from '$lib/utilities/dates/datesToStatusObject';
	import DaysLeft from '$lib/components/events/DaysLeft.svelte';
	import EventStatus from '$lib/components/events/EventStatus.svelte';

	export let event;
	export let claims;

	let actualStatus: {
		status: string;
		daysRemaining: number;
	};

	event.verifiers.forEach((verifier: any) => {
		if (verifier.dateStart && verifier.dateEnding) {
			actualStatus = datesToStatusObject(verifier.dateStart, verifier.dateEnding);
		}
	});
</script>

<div class="main-wrapper">
	<div class="top-wrapper">
		<div class="column-wrapper">
			<EventStatus {actualStatus} />
		</div>
		<div class="column-wrapper">
			<h5>{event.totalSupply}</h5>
			<p class="small">FLOATs claimed</p>
		</div>
		{#if actualStatus}
			<div class="column-wrapper">
				<DaysLeft {actualStatus} />
			</div>
		{/if}
	</div>
	<div class="ticket-wrapper">
		<FloatTicket float={transformEventToFloat(event)} />
	</div>
	<div class="claims-wrapper">
		<div class="row-1 claims-title-wrapper">
			<Icon icon="tabler:news" color="var(--clr-neutral-600)" />
			<p>LATEST CLAIMS</p>
		</div>
		<div class="claim-tickets">
			{#each claims as claim, i}
				<ClaimTicketCard {claim} {i} />
			{/each}
		</div>
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		display: flex;
		flex-direction: column;
		justify-content: center;
		align-items: center;
		gap: var(--space-10);
		height: 100%;

		.top-wrapper {
			display: flex;
			justify-content: space-between;
			width: 100%;
			align-items: center;
			padding: var(--space-4) var(--space-8);
			border-bottom: var(--border-width-primary) dashed var(--clr-border-primary);

			@include mq(small) {
				padding: var(--space-4) var(--space-18);
			}

			@include mq(medium) {
				padding: var(--space-6) var(--space-15) var(--space-6) var(--space-12);
			}

			.column-wrapper {
				display: flex;
				flex-direction: column;
				justify-content: center;
				align-items: center;

				h5 {
					margin: 0;
				}
			}
		}

		.ticket-wrapper {
			width: 100%;

			@include mq(medium) {
				padding: 0 var(--space-15) 0 var(--space-12);
			}
		}

		.claims-wrapper {
			display: flex;
			flex-direction: column;
			justify-content: center;
			width: 100%;
			justify-content: center;
			max-height: 100%;
			overflow-y: hidden;

			.claims-title-wrapper {
				padding: var(--space-2) var(--space-12);
				display: flex;
				align-items: center;
				justify-content: flex-start;
				width: 100%;
				border-bottom: 0.5px solid var(--clr-border-primary);
			}

			.claim-tickets {
				display: flex;
				padding: var(--space-2) var(--space-12);
				flex-direction: column;
				gap: var(--space-3);
				overflow-y: auto;
				padding-top: var(--space-3);
			}
		}
	}
</style>
