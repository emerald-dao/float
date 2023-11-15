<script lang="ts">
	import Blur from '$lib/components/Blur.svelte';
	import { Currency } from '@emerald-dao/component-library';
	import transformEventToFloat from '$lib/utilities/transformEventToFloat';
	import { unixTimestampToFormattedDate } from '$lib/utilities/dates/unixTimestampToFormattedDate';
	import Icon from '@iconify/svelte';
	import EventStatus from '$lib/components/events/EventStatus.svelte';
	import Float from '$lib/components/floats/Float.svelte';
	import ClaimButtonStatus from '../../_components/ClaimButtonStatus.svelte';
	import PowerUpCards from '$lib/features/event-status-management/power-ups-cards/PowerUpCards.svelte';
	import ClaimTicketCard from '../../../admin/events/atoms/ClaimTicketCard.svelte';
	import { user } from '$stores/flow/FlowStore';
	import { secondsToDhms } from '$lib/utilities/dates/secondsToDhms';
	import SeeMoreSidebar from '../../_components/SeeMoreSidebar.svelte';

	export let data;

	let startDate = data.event.verifiers.timelock?.dateStart
		? Number(data.event.verifiers.timelock.dateStart)
		: Number(data.event.dateCreated);
	let endDate = data.event.verifiers.timelock?.dateEnding
		? Number(data.event.verifiers.timelock.dateEnding)
		: null;
	$: currentUnixTime = +new Date() / 1000;
	setInterval(() => (currentUnixTime = +new Date() / 1000), 1000);

	let secretCode = data.event.verifiers.secret?.secret ?? '';
	let requireEmail = data.event.verifiers.requireEmail != undefined;

	let seeMore = false;
</script>

{#if data.event.description}
	<div class="hide-on-mobile">
		<div class="description-button" on:click={() => (seeMore = !seeMore)} on:keydown>
			<Icon icon="tabler:arrow-left" />
			<p class="xsmall w-medium">About this event</p>
		</div>
		{#if seeMore}
			<SeeMoreSidebar
				description={data.event.description}
				on:closeModal={() => (seeMore = !seeMore)}
			/>
		{/if}
	</div>
{/if}

<section class="container-medium">
	<div class="main-wrapper">
		<div class="side-wrapper event-id">
			<h4 class="w-medium">{`#${data.event.eventId}`}</h4>
			<p class="small">Event ID</p>
		</div>
		<div class="float-ticket-wrapper">
			<Blur color="tertiary" right="15%" top="10%" />
			<Blur left="15%" top="10%" />
			<Float float={transformEventToFloat(data.event, $user.addr)} />
		</div>
		<div class="side-wrapper floats-minted">
			<h4 class="w-medium">{`${data.event.totalSupply}`}</h4>
			<p class="small">FLOATs claimed</p>
		</div>
	</div>
	{#if Object.keys(data.event.verifiers).length > 0}
		<div class="column-4">
			<p class="w-medium">
				<Icon icon="tabler:plus" inline />
				Power Ups
			</p>
			<PowerUpCards powerUps={data.event.verifiers} price={data.event.price} />
		</div>
	{/if}
	<div class="details-wrapper">
		<div class="row-2 align-center">
			<EventStatus
				status={data.event.status.generalStatus}
				claimability={data.event.claimable}
				limitedStatus={data.event.status.verifiersStatus.limitedStatus}
				timelockStatus={data.event.status.verifiersStatus.timelockStatus}
			/>
		</div>

		{#if startDate > currentUnixTime}
			<!-- Has not started yet -->
			<div>
				<p class="large">{secondsToDhms(startDate - currentUnixTime)}</p>
				<p class="small">Starting in</p>
			</div>
		{:else}
			<!-- Has started -->
			<div>
				<p class="large">{unixTimestampToFormattedDate(startDate.toString())}</p>
				<p class="small">Start Date</p>
			</div>
		{/if}

		{#if endDate}
			{#if startDate > currentUnixTime || currentUnixTime >= endDate}
				<!-- Has not started or event is over -->
				<div>
					<p class="large">{unixTimestampToFormattedDate(endDate.toString())}</p>
					<p class="small">End Date</p>
				</div>
			{:else if currentUnixTime < endDate}
				<!-- Has not ended -->
				<div>
					<p class="large">{secondsToDhms(endDate - currentUnixTime)}</p>
					<p class="small">Ends in</p>
				</div>
			{/if}
		{/if}

		<div>
			{#if !data.event.price}
				<p class="large">Free</p>
			{:else}
				<Currency
					amount={data.event.price}
					currency={'FLOW'}
					fontSize={'18px'}
					decimalNumbers={2}
					thinCurrency={false}
				/>
			{/if}
			<p class="small">Price</p>
		</div>
	</div>
	<ClaimButtonStatus
		event={data.event}
		{secretCode}
		{requireEmail}
		free={data.event.price !== null || Number(data.event.price) === 0}
	/>
</section>
<section class="container-small claims-wrapper">
	<div class="row-1 claims-title-wrapper align-center">
		<Icon icon="tabler:news" color="var(--clr-neutral-600)" />
		<p>LATEST CLAIMS</p>
	</div>
	<div class="column-3 claims-cards-wrapper">
		{#if data.claims.length === 0}
			<p>No claims yet</p>
		{:else}
			{#each data.claims as claim (claim.serial)}
				<ClaimTicketCard {claim} />
			{/each}
		{/if}
	</div>
</section>

<style lang="scss">
	section:first-of-type {
		position: relative;
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		gap: var(--space-10);
		flex: 1;
		border-bottom: 1px dashed var(--clr-border-primary);

		@include mq(medium) {
			min-height: 80vh;
		}

		.main-wrapper {
			display: grid;
			grid-auto-columns: 1fr;
			grid-template-columns: 1fr 1fr;
			grid-template-rows: auto auto 1fr;
			gap: var(--space-12) var(--space-6);
			width: 100%;
			grid-template-areas:
				'event-id event-id'
				'floats-minted floats-minted'
				'float-ticket float-ticket';

			.event-id {
				grid-area: event-id;
			}
			.floats-minted {
				grid-area: floats-minted;
			}

			@include mq(medium) {
				grid-template-columns: 2fr 7fr 2fr;
				grid-template-rows: 1fr;
				justify-content: center;
				align-items: center;
				text-align: center;
				gap: var(--space-16);
				grid-template-areas: 'event-id float-ticket floats-minted';
			}

			.side-wrapper {
				display: flex;
				flex-direction: column;
				align-items: center;

				h4 {
					color: var(--clr-text-main);
					font-size: var(--font-size-2);
				}

				p {
					color: var(--clr-text-off);
				}
			}

			.float-ticket-wrapper {
				grid-area: float-ticket;
				display: flex;
				align-items: center;
				justify-content: center;
				width: 100%;
				position: relative;
			}
		}

		.details-wrapper {
			display: flex;
			flex-direction: row;
			flex-wrap: wrap;
			gap: var(--space-12);
			justify-content: center;
			align-items: center;
			border-block: 1px dashed var(--clr-border-primary);
			padding: var(--space-5) var(--space-12);
			text-align: center;

			@include mq(medium) {
				flex-direction: row;
				gap: var(--space-18);
			}

			.small {
				color: var(--clr-text-off);
			}
		}
	}

	.claims-wrapper {
		display: flex;
		flex-direction: column;
		gap: var(--space-5);
		align-items: flex-start;

		.claims-cards-wrapper {
			width: 100%;
		}
	}

	.description-button {
		position: fixed;
		right: 0;
		top: 20vh;
		display: flex;
		align-items: center;
		padding: var(--space-2) var(--space-4);
		border-right-width: 0px;
		border-radius: var(--radius-1) 0px 0px var(--radius-1);
		cursor: pointer;
		background-color: var(--clr-surface-secondary);
		gap: var(--space-1);
	}
</style>
