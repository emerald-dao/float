<script lang="ts">
	import { user } from '$stores/flow/FlowStore';
	import Icon from '@iconify/svelte';
	import ClaimTicketCard from '../../atoms/ClaimTicketCard.svelte';
	import transformEventToFloat from '$lib/utilities/transformEventToFloat';
	import EventStatus from '$lib/components/events/EventStatus.svelte';
	import type { EventWithStatus } from '$lib/types/event/event.interface';
	import TimelockStateLabel from '$lib/features/event-status-management/components/TimelockStateLabel.svelte';
	import LimitedStateLabel from '$lib/features/event-status-management/components/LimitedStateLabel.svelte';
	import Float from '$lib/components/floats/Float.svelte';
	import { getLatestEventClaims } from '$flow/actions';

	export let event: EventWithStatus;

	let userAddress = $user.addr as string;
</script>

<div class="main-wrapper">
	<div class="top-wrapper">
		<div class="column align-center">
			<h4 class="h5">{event.totalSupply}</h4>
			<p class="small">FLOATs claimed</p>
		</div>
		<div class="row-2">
			{#if event.status.verifiersStatus && (event.status.verifiersStatus.timelockStatus !== null || event.status.verifiersStatus.limitedStatus !== null)}
				{#if event.status.verifiersStatus.timelockStatus}
					<TimelockStateLabel timelockStatus={event.status.verifiersStatus.timelockStatus} />
				{/if}
				{#if event.status.verifiersStatus.limitedStatus}
					<LimitedStateLabel limitedStatus={event.status.verifiersStatus.limitedStatus} />
				{/if}
			{/if}
			<EventStatus status={event.status.generalStatus} />
		</div>
	</div>
	<div class="ticket-wrapper">
		<Float float={transformEventToFloat(event)} />
	</div>
	<div class="claims-wrapper">
		<div class="row-1 claims-title-wrapper">
			<Icon icon="tabler:news" color="var(--clr-neutral-600)" />
			<p>LATEST CLAIMS</p>
		</div>
		<div class="claim-tickets">
			{#await getLatestEventClaims(userAddress, event.eventId, 20)}
				<p class="small"><em>Loading claims</em></p>
			{:then claims}
				{#if claims.length === 0}
					<p class="small"><em>No claims yet</em></p>
				{/if}
				{#each claims as claim}
					<ClaimTicketCard {claim} />
				{/each}
			{:catch error}
				<p class="small"><em>Couldn't fetch claims</em></p>
			{/await}
		</div>
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		display: flex;
		flex-direction: column;
		justify-content: flex-start;
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

			em {
				color: var(--clr-text-off);
			}
		}
	}
</style>
