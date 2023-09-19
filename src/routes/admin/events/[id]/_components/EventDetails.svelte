<script lang="ts">
	import ClaimTicketCard from '../../atoms/ClaimTicketCard.svelte';
	import transformEventToFloat from '$lib/utilities/transformEventToFloat';
	import EventStatus from '$lib/components/events/EventStatus.svelte';
	import type { EventWithStatus } from '$lib/types/event/event.interface';
	import type { Claim } from '$lib/types/event/event-claim.interface';
	import Float from '$lib/components/floats/Float.svelte';
	import { user } from '$stores/flow/FlowStore';
	import { onMount } from 'svelte';
	import { getLatestEventClaims } from '$flow/actions';
	import EventDataTitle from '../../_components/EventDataTitle.svelte';
	import PowerUpCards from '$lib/features/event-status-management/power-ups-cards/PowerUpCards.svelte';

	export let event: EventWithStatus;

	let claims: Claim[] = [];
	let userAddress = $user.addr as string;

	onMount(async () => {
		claims = await getLatestEventClaims(userAddress, event.eventId, 20);
	});
</script>

<div class="main-wrapper">
	<div class="ticket-wrapper">
		<div class="data-wrapper">
			<div class="column number-of-claims-wrapper">
				<p class="large w-medium">{`${event.totalSupply}`}</p>
				<p class="xsmall off">FLOATs claimed</p>
			</div>
			<div class="event-status-wrapper">
				<EventStatus status={event.status.generalStatus} claimability={event.claimable} />
			</div>
		</div>
		<div class="float-wrapper">
			<Float float={transformEventToFloat(event)} maxWidth="450px" />
		</div>
	</div>
	{#if Object.keys(event.verifiers).length > 0 || (event.price && Number(event.price) > 0)}
		<div class="powerups-main-wrapper">
			<EventDataTitle icon="tabler:plus">Power ups</EventDataTitle>
			<PowerUpCards powerUps={event.verifiers} price={event.price} numberOfClaims={claims.length} />
		</div>
	{/if}
	<div class="claims-wrapper">
		<EventDataTitle icon="tabler:news">Latest claims</EventDataTitle>
		{#if claims.length === 0}
			<p class="small"><em>No claims yet</em></p>
		{/if}
		{#each claims as claim}
			<ClaimTicketCard {claim} />
		{/each}
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		display: flex;
		flex-direction: column;
		justify-content: flex-start;
		align-items: center;
		height: 100%;

		.powerups-main-wrapper,
		.ticket-wrapper,
		.claims-wrapper {
			border-bottom: 1px solid var(--clr-neutral-badge);
			padding: var(--space-6) var(--space-10);
			width: 100%;

			&:last-child {
				border: none;
			}
		}

		.powerups-main-wrapper {
			display: flex;
			flex-direction: column;
			gap: var(--space-3);
		}

		.ticket-wrapper {
			display: grid;
			grid-template-columns: 1fr 3fr;
			padding-block: var(--space-10);

			.data-wrapper {
				display: flex;
				flex-direction: column;
				gap: var(--space-5);
				height: 100%;

				.number-of-claims-wrapper,
				.event-status-wrapper {
					padding-right: var(--space-6);
				}

				.event-status-wrapper {
					border-top: 1px solid var(--clr-neutral-badge);
					padding-top: var(--space-5);
				}

				.number-of-claims-wrapper {
					align-items: center;

					.off {
						color: var(--clr-text-off);
						opacity: 0.7;
					}
				}
			}

			.float-wrapper {
				border-left: 1px solid var(--clr-neutral-badge);
				width: 100%;
				padding-left: var(--space-8);
			}
		}

		.claims-wrapper {
			display: flex;
			flex-direction: column;
			justify-content: center;
			overflow-y: auto;
			gap: var(--space-3);

			em {
				color: var(--clr-text-off);
			}
		}
	}
</style>
