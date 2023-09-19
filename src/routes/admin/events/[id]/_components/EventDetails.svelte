<script lang="ts">
	import ClaimTicketCard from '../../atoms/ClaimTicketCard.svelte';
	import transformEventToFloat from '$lib/utilities/transformEventToFloat';
	import EventStatus from '$lib/components/events/EventStatus.svelte';
	import type { EventWithStatus } from '$lib/types/event/event.interface';
	import type { Claim } from '$lib/types/event/event-claim.interface';
	import Float from '$lib/components/floats/Float.svelte';
	import TimelockReview from '$lib/features/event-status-management/power-ups-cards/cards/TimelockReview.svelte';
	import LimitedReview from '$lib/features/event-status-management/power-ups-cards/cards/LimitedReview.svelte';
	import PaymentReview from '$lib/features/event-status-management/power-ups-cards/cards/PaymentReview.svelte';
	import MinimumBalanceReview from '$lib/features/event-status-management/power-ups-cards/cards/MinimumBalanceReview.svelte';
	import SecretCodeReview from '$lib/features/event-status-management/power-ups-cards/cards/SecretCodeReview.svelte';
	import { user } from '$stores/flow/FlowStore';
	import { onMount } from 'svelte';
	import { getLatestEventClaims } from '$flow/actions';
	import EventDataTitle from '../../_components/EventDataTitle.svelte';

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
			<div class="powerups-cards-wrapper">
				{#if event.verifiers.timelock}
					<TimelockReview
						startDate={event.verifiers.timelock.dateStart}
						endDate={event.verifiers.timelock.dateEnding}
					/>
				{/if}
				{#if event.verifiers.limited}
					<LimitedReview
						maxSupply={Number(event.verifiers.limited.capacity)}
						claims={claims.length}
					/>
				{/if}
				{#if event.price}
					<PaymentReview price={event.price} />
				{/if}
				{#if event.verifiers.minimumBalance}
					<MinimumBalanceReview balanceAmount={Number(event.verifiers.minimumBalance.amount)} />
				{/if}
				{#if event.verifiers.secret}
					<SecretCodeReview secretCode={event.verifiers.secret.publicKey} isAdmin={true} />
				{/if}
				{#if event.price && Number(event.price) > 0}
					<PaymentReview price={event.price} />
				{/if}
			</div>
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

			.powerups-cards-wrapper {
				display: flex;
				flex-direction: row;
				gap: var(--space-3);
				flex-wrap: wrap;
				align-items: flex-start;
			}
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
