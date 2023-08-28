<script lang="ts">
	import { fly } from 'svelte/transition';
	import Blur from '$lib/components/Blur.svelte';
	import { Button, Currency } from '@emerald-dao/component-library';
	import claimFloat from '../../../../routes/event/_actions/claimFloat';
	import transformEventToFloat from '$lib/utilities/transformEventToFloat';
	import { unixTimestampToFormattedDate } from '$lib/utilities/dates/unixTimestampToFormattedDate';
	import type { Secret, Timelock } from '$lib/types/event/verifiers.interface';
	import Icon from '@iconify/svelte';
	import ClaimTicketCard from '../../../admin/[userAddress]/events/atoms/ClaimTicketCard.svelte';
	import TimelockStateLabel from '$lib/features/event-status-management/components/TimelockStateLabel.svelte';
	import LimitedStateLabel from '$lib/features/event-status-management/components/LimitedStateLabel.svelte';
	import EventStatus from '$lib/components/events/EventStatus.svelte';
	import Float from '$lib/components/floats/Float.svelte';
	import validateSecretCode from '../../_actions/validateSecretCode';
	import { get } from 'svelte/store';
	import { user } from '$stores/flow/FlowStore';
	import { logIn } from '$flow/actions';

	export let data;

	let starDate: string;
	let endDate: string;
	let dates = {
		dateStart: '',
		dateEnding: ''
	};
	let secretCode: string;
	let inputValue = '';
	let secretCodeValidation: boolean;

	data.event.verifiers.forEach((verifier) => {
		if (verifier.hasOwnProperty('dateStart')) {
			dates.dateStart = (verifier as Timelock).dateStart;
		}
		if ((verifier as Timelock).dateEnding) {
			dates.dateEnding = (verifier as Timelock).dateEnding;
		}
		if (verifier.hasOwnProperty('publicKey')) {
			secretCode = (verifier as Secret).publicKey;
		}
	});

	if (dates.dateStart && dates.dateEnding) {
		starDate = unixTimestampToFormattedDate(dates.dateStart);
		endDate = unixTimestampToFormattedDate(dates.dateEnding);
	} else {
		starDate = unixTimestampToFormattedDate(data.event.dateCreated);
	}

	const handleChange = async () => {
		if (!$user.loggedIn) {
			await logIn();
		}
		secretCodeValidation = await validateSecretCode(
			data.event.eventId,
			data.event.host,
			inputValue,
			get(user).addr
		);
	};
</script>

<section class="container-medium">
	<div class="main-wrapper">
		<div class="side-wrapper event-id">
			<h4>{`# ${data.event.eventId}`}</h4>
			<p class="small">Event ID</p>
		</div>
		<div class="float-ticket-wrapper">
			<Blur color="tertiary" right="15%" top="10%" />
			<Blur left="15%" top="10%" />
			<Float float={transformEventToFloat(data.event)} />
		</div>
		<div class="side-wrapper floats-minted">
			<h4>{`${data.event.totalSupply}`}</h4>
			<p class="small">FLOATs claimed</p>
		</div>
	</div>
	<div class="details-wrapper">
		<div class="row-2 align-center">
			{#if data.event.status.verifiersStatus && (data.event.status.verifiersStatus.timelockStatus !== null || data.event.status.verifiersStatus.limitedStatus !== null)}
				{#if data.event.status.verifiersStatus.timelockStatus}
					<TimelockStateLabel timelockStatus={data.event.status.verifiersStatus.timelockStatus} />
				{/if}
				{#if data.event.status.verifiersStatus.limitedStatus}
					<LimitedStateLabel limitedStatus={data.event.status.verifiersStatus.limitedStatus} />
				{/if}
			{/if}
			<EventStatus status={data.event.status.generalStatus} />
		</div>
		{#if starDate && endDate}
			<div>
				<p class="large">{starDate}</p>
				<p class="small">Start Date</p>
			</div>
			<div>
				<p class="large">{endDate}</p>
				<p class="small">End Date</p>
			</div>
		{:else}
			<div>
				<p class="large">{starDate}</p>
				<p class="small">Start Date</p>
			</div>
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
	<div class="button-wrapper">
		{#if secretCode}
			<div
				class="secret-code-message"
				class:success={secretCodeValidation === true}
				class:alert={!secretCodeValidation}
			>
				{#if secretCodeValidation === false}
					<div class="row-1 align-center justify-center" in:fly={{ duration: 300, y: -10 }}>
						<Icon icon="tabler:lock" />
						<span>Code is incorrect</span>
					</div>
				{:else if secretCodeValidation === true}
					<div class="row-1 align-center justify-center" in:fly={{ duration: 300, y: -10 }}>
						<Icon icon="tabler:lock-open" />
						<span>Unlocked</span>
					</div>
				{:else}
					<div class="row-1 align-center justify-center" in:fly={{ duration: 300, y: -10 }}>
						<Icon icon="tabler:lock" />
						<span>Locked by a secret code</span>
					</div>
				{/if}
			</div>
			<div class="input-wrapper">
				<input type="password" placeholder="Insert secret code" max="60" bind:value={inputValue} />
				<button
					class="input-button row-1 align-center"
					on:click={handleChange}
					disabled={inputValue.length < 1}
				>
					Send
					<Icon icon="tabler:arrow-right" />
				</button>
			</div>
		{/if}
		<div class="button-background">
			{#if secretCode}
				<Button
					size="large"
					width="full-width"
					state={secretCodeValidation ? 'active' : 'disabled'}
					on:click={() => claimFloat(data.event.eventId, data.event.host)}
				>
					Claim FLOAT
				</Button>
			{:else}
				<Button
					size="large"
					width="full-width"
					on:click={() => claimFloat(data.event.eventId, data.event.host)}
				>
					Claim FLOAT
				</Button>
			{/if}
		</div>
	</div>
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
			{#each data.claims as claim}
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
		gap: var(--space-13);
		flex: 1;
		border-bottom: 1px dashed var(--clr-border-primary);

		@include mq(medium) {
			min-height: 80vh;
		}

		.main-wrapper {
			display: grid;
			grid-auto-columns: 1fr;
			grid-template-columns: 1fr 1fr;
			grid-template-rows: auto 1fr;
			gap: var(--space-12) var(--space-6);
			width: 100%;
			grid-template-areas:
				'event-id floats-minted'
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
					font-size: var(--font-size-5);
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
			}
		}

		.details-wrapper {
			display: flex;
			flex-direction: row;
			gap: var(--space-18);
			justify-content: center;
			align-items: center;
			border-block: 1px dashed var(--clr-border-primary);
			padding: var(--space-5) var(--space-12);
			text-align: center;

			.small {
				color: var(--clr-text-off);
			}
		}

		.button-wrapper {
			position: fixed;
			bottom: 0;
			width: 100%;
			z-index: 30;
			border-top-left-radius: var(--radius-4);
			border-top-right-radius: var(--radius-4);

			@include mq(small) {
				display: flex;
				flex-direction: column;
				position: relative;
				width: 230px;
				background-color: transparent;
				gap: var(--space-3);
			}

			.input-wrapper {
				position: relative;

				input {
					border-radius: 0%;
					background: var(--clr-surface-primary);
					z-index: 30;

					@include mq(small) {
						border-radius: var(--radius-1);
						padding-right: var(--space-13);
						box-sizing: border-box;
					}
				}

				.input-button {
					position: absolute;
					right: 2px;
					top: 50%;
					transform: translateY(-50%);
					background: none;
					border: none;
					cursor: pointer;
					z-index: 1;
					font-size: var(--font-size-1);
				}
			}

			.secret-code-message {
				justify-content: center;
				align-items: center;
				font-size: var(--font-size-1);
				padding-left: var(--space-2);

				&.alert {
					color: var(--clr-alert-main);
				}

				&.success {
					color: var(--clr-primary-main);
				}
			}

			.button-background {
				background-color: var(--clr-primary-main);

				@include mq(small) {
					background: none;
				}
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
</style>
