<script lang="ts">
	import type { EventWithStatus } from '$lib/types/event/event.interface';
	import { user } from '$stores/flow/FlowStore';
	import { Button } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';
	import { fly } from 'svelte/transition';
	import validateSecretCode from '../_actions/validateSecretCode';
	import { logIn, userHasClaimedEvent } from '$flow/actions';
	import { get } from 'svelte/store';
	import claimFloat from '../_actions/claimFloat';
	import { page } from '$app/stores';

	export let event: EventWithStatus;
	export let secretCode: string;

	let floatAlreadyClaimed: boolean;

	$: if ($user.addr) {
		checkIfUserHasClaimedEvent();
	}

	async function checkIfUserHasClaimedEvent() {
		floatAlreadyClaimed = await userHasClaimedEvent($page.params.eventId, event.host, $user.addr);
	}

	let inputValue = '';
	let secretCodeValidation: boolean;

	const handleChange = async () => {
		if (!$user.loggedIn) {
			await logIn();
		}
		secretCodeValidation = await validateSecretCode(
			event.eventId,
			event.host,
			inputValue,
			get(user).addr
		);
	};
</script>

<div class="button-wrapper">
	{#if event.status.generalStatus === 'available' && event.claimable}
		{#if !$user.loggedIn}
			<div class="secret-code-message">
				<div class="row-1 align-center justify-center" in:fly={{ duration: 300, y: -10 }}>
					<Icon icon="tabler:wallet" />
					<span>Connect to claim the event</span>
				</div>
			</div>
		{:else if floatAlreadyClaimed}
			<div class="secret-code-message">
				<div class="row-1 align-center justify-center" in:fly={{ duration: 300, y: -10 }}>
					<Icon icon="tabler:lock" />
					<span>You already own this FLOAT</span>
				</div>
			</div>
		{:else if secretCode}
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
	{:else}
		<div class="secret-code-message">
			<div class="row-1 align-center justify-center" in:fly={{ duration: 300, y: -10 }}>
				<Icon icon="tabler:lock" />
				{#if !event.claimable}
					<span>This event is non-claimable</span>
				{:else if event.status.generalStatus === 'expired'}
					<span>The event has {event.status.generalStatus}</span>
				{:else}
					<span>The event is {event.status.generalStatus}</span>
				{/if}
			</div>
		</div>
	{/if}
	<div class="button-background">
		{#if event.status.generalStatus === 'available'}
			{#if !$user.loggedIn || floatAlreadyClaimed}
				<Button size="large" width="full-width" state="disabled">Claim FLOAT</Button>
			{:else if secretCode}
				<Button
					size="large"
					width="full-width"
					state={secretCodeValidation ? 'active' : 'disabled'}
					on:click={() => claimFloat(event.eventId, event.host, inputValue)}
				>
					Claim FLOAT
				</Button>
			{:else}
				<Button
					size="large"
					width="full-width"
					on:click={() => claimFloat(event.eventId, event.host, undefined)}
				>
					Claim FLOAT
				</Button>
			{/if}
		{:else}
			<Button size="large" width="full-width" state="disabled">Claim FLOAT</Button>
		{/if}
	</div>
</div>

<style lang="scss">
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
</style>
