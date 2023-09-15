<script lang="ts">
	import Icon from '@iconify/svelte';
	import ClaimTicketCard from '../../atoms/ClaimTicketCard.svelte';
	import transformEventToFloat from '$lib/utilities/transformEventToFloat';
	import EventStatus from '$lib/components/events/EventStatus.svelte';
	import type { EventWithStatus } from '$lib/types/event/event.interface';
	import type { Claim } from '$lib/types/event/event-claim.interface';
	import Float from '$lib/components/floats/Float.svelte';
	import TimelockReview from '$lib/features/event-generator/components/steps/7-Review/powerUpsReview/cards/TimelockReview.svelte';
	import LimitedReview from '$lib/features/event-generator/components/steps/7-Review/powerUpsReview/cards/LimitedReview.svelte';
	import PaymentReview from '$lib/features/event-generator/components/steps/7-Review/powerUpsReview/cards/PaymentReview.svelte';
	import type { MinimumBalance, Secret } from '$lib/types/event/verifiers.interface';
	import MinimumBalanceReview from '$lib/features/event-generator/components/steps/7-Review/powerUpsReview/cards/MinimumBalanceReview.svelte';
	import SecretCodeReview from '$lib/features/event-generator/components/steps/7-Review/powerUpsReview/cards/SecretCodeReview.svelte';

	export let event: EventWithStatus;
	export let claims: Claim[] = [];

	let amount: string;
	let secretCode: string;
	event.verifiers.forEach((verifier) => {
		if (verifier.hasOwnProperty('amount')) {
			amount = (verifier as MinimumBalance).amount;
		}
		if (verifier.hasOwnProperty('publicKey')) {
			secretCode = (verifier as Secret).publicKey;
		}
	});
</script>

<div class="main-wrapper">
	<div class="main-info-wrapper">
		<div class="top-wrapper">
			<div class="column align-center">
				<h4 class="h5">{event.totalSupply}</h4>
				<p class="small">FLOATs claimed</p>
			</div>
			<div>
				<EventStatus status={event.status.generalStatus} claimability={event.claimable} />
			</div>
		</div>
		{#if event.verifiers.length > 0}
			<div class="powerups-main-wrapper">
				<div class="title-wrapper">
					<Icon icon="tabler:plus" />
					<p class="w-medium">Power Ups</p>
				</div>
				<div class="powerups-cards-wrapper">
					{#if event.status.verifiersStatus && (event.status.verifiersStatus.timelockStatus !== null || event.status.verifiersStatus.limitedStatus !== null)}
						{#if event.status.verifiersStatus.timelockStatus}
							<div>
								<TimelockReview
									timelockStatus={event.status.verifiersStatus.timelockStatus}
									{event}
								/>
							</div>
						{/if}
						{#if event.status.verifiersStatus.limitedStatus}
							<div>
								<LimitedReview limitedStatus={event.status.verifiersStatus.limitedStatus} {event} />
							</div>
						{/if}
					{/if}
					{#if event.price}
						<div>
							<PaymentReview {event} />
						</div>
					{/if}
					{#if amount}
						<div>
							<MinimumBalanceReview {event} />
						</div>
					{/if}
					{#if secretCode}
						<div>
							<SecretCodeReview {event} />
						</div>
					{/if}
				</div>
			</div>
		{/if}
	</div>
	<div class="ticket-wrapper">
		<Float float={transformEventToFloat(event)} maxWidth="450px" />
	</div>
	<div class="claims-wrapper">
		<div class="row-1 claims-title-wrapper">
			<Icon icon="tabler:news" color="var(--clr-neutral-600)" />
			<p>LATEST CLAIMS</p>
		</div>
		<div class="claim-tickets">
			{#if claims.length === 0}
				<p class="small"><em>No claims yet</em></p>
			{/if}
			{#each claims as claim}
				<ClaimTicketCard {claim} />
			{/each}
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

		.main-info-wrapper {
			width: 100%;

			.top-wrapper {
				display: flex;
				justify-content: space-between;
				width: 100%;
				align-items: center;
				padding: var(--space-4) var(--space-8);
				border-bottom: var(--border-width-primary) dashed var(--clr-border-primary);

				@include mq(small) {
					padding: var(--space-3) var(--space-18);
				}

				@include mq(medium) {
					padding: var(--space-3) var(--space-15) var(--space-3) var(--space-12);
				}
			}

			.powerups-main-wrapper {
				padding: var(--space-3) var(--space-15) var(--space-3) var(--space-12);
				border-bottom: var(--border-width-primary) dashed var(--clr-border-primary);

				.title-wrapper {
					display: flex;
					flex-direction: row;
					align-items: center;
					padding-bottom: var(--space-2);
				}

				.powerups-cards-wrapper {
					display: flex;
					flex-direction: row;
					gap: var(--space-2);
					flex-wrap: wrap;
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

			em {
				color: var(--clr-text-off);
			}
		}
	}
</style>
