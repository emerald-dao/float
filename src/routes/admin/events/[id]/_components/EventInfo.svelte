<script lang="ts">
	import FloatTicket from '$lib/components/floats/FloatTicket.svelte';
	import Icon from '@iconify/svelte';
	import ClaimTicket from './atoms/ClaimTicket.svelte';
	import transformEventToFloat from '$lib/utilities/transformEventToFloat';
	import { compareDates } from '$lib/utilities/compareDates';
	import Status from './atoms/Status.svelte';
	import DaysLeft from './atoms/DaysLeft.svelte';

	export let event;
	export let claims;
	let actualStatus: {
		status: string;
		daysRemaining: number;
	};

	event.verifiers.forEach((verifier: any) => {
		if (verifier.dateStart && verifier.dateEnding) {
			actualStatus = compareDates(verifier.dateStart, verifier.dateEnding);
		}
	});
</script>

<div class="main-wrapper">
	<div class="top-wrapper">
		<div class="column-wrapper">
			<Status {actualStatus} />
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
		<div class="row-1">
			<Icon icon="tabler:news" color="var(--clr-neutral-600)" />
			<p>LATEST CLAIMS</p>
		</div>
		{#each claims as claim}
			<ClaimTicket {claim} />
		{/each}
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		display: flex;
		flex-direction: column;
		justify-content: center;
		align-items: center;
		gap: var(--space-10);

		.top-wrapper {
			display: flex;
			justify-content: space-between;
			width: 100%;
			align-items: center;
			padding: var(--space-4) var(--space-4);
			border-bottom: var(--border-width-primary) dashed var(--clr-border-primary);

			@include mq(medium) {
				padding: var(--space-6) var(--space-12);
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
			padding: 0 var(--space-3);
		}

		.claims-wrapper {
			display: flex;
			flex-direction: column;
			justify-content: center;
			width: 100%;
			justify-content: center;
			gap: var(--space-4);

			.row-1 {
				display: flex;
				align-items: center;
				justify-content: flex-start;
				padding: var(--space-2) var(--space-12);
				width: 100%;
				border-bottom: var(--border-width-primary) dashed var(--clr-border-primary);
			}
		}
	}
</style>
