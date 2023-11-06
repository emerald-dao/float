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
	import { invalidate } from '$app/navigation';
	import validateEmail from '../_actions/validateEmail';

	export let event: EventWithStatus;
	export let secretCode: string;
	export let requireEmail: boolean;
	export let free: boolean;

	let redirectUrl: string | null;
	if (typeof window !== 'undefined') {
		const urlSearchParams = new URLSearchParams(window.location.search);
		redirectUrl = urlSearchParams.get('redirect');
	}

	let floatAlreadyClaimed: boolean;

	$: if ($user.addr) {
		checkIfUserHasClaimedEvent();
	}

	async function checkIfUserHasClaimedEvent() {
		floatAlreadyClaimed = await userHasClaimedEvent(
			$page.params.eventId,
			event.host,
			$user.addr as string
		);
	}

	let secretCodeInputValue = '';
	let secretCodeValidation: boolean;

	let requireEmailInputValue = '';
	let requireEmailValidation: boolean;

	let powerUpErrorMessage = '';

	const handleClaimFloat = async () => {
		if (!$user.loggedIn) {
			await logIn();
		}
		// check if secret code is correct first
		if (secretCode) {
			secretCodeValidation = await validateSecretCode(
				event.eventId,
				event.host,
				secretCodeInputValue,
				get(user).addr as string
			);
			if (secretCodeValidation === false) {
				powerUpErrorMessage = 'Code is incorrect';
				return;
			}
		}
		if (requireEmail) {
			requireEmailValidation = validateEmail(requireEmailInputValue);
			if (requireEmailValidation === false) {
				powerUpErrorMessage = 'Email is formatted incorrectly';
				return;
			}
		}
		powerUpErrorMessage = 'Unlocked';
		await claimFloat(event.eventId, event.host, secretCodeInputValue, requireEmailInputValue, free);

		invalidate('app:event');

		checkIfUserHasClaimedEvent();

		if (redirectUrl !== null) {
			const nonNullRedirectUrl: string = redirectUrl;

			setTimeout(() => {
				window.location.href = nonNullRedirectUrl;
			}, 3000);
		}
	};
</script>

<div class="button-wrapper">
	{#if event.status.generalStatus === 'available' && event.claimable}
		{#if $user.loggedIn && floatAlreadyClaimed && event.multipleClaim}
			<div class="secret-code-message">
				<div class="row-1 align-center justify-center" in:fly={{ duration: 300, y: -10 }}>
					<Icon icon="tabler:info-circle" />
					<span>You already own this FLOAT</span>
				</div>
			</div>
		{/if}
		{#if !$user.loggedIn}
			<div class="secret-code-message">
				<div class="row-1 align-center justify-center" in:fly={{ duration: 300, y: -10 }}>
					<Icon icon="tabler:wallet" />
					<span>Connect to claim the event</span>
				</div>
			</div>
		{:else if floatAlreadyClaimed && !event.multipleClaim}
			<div class="secret-code-message">
				<div class="row-1 align-center justify-center" in:fly={{ duration: 300, y: -10 }}>
					<Icon icon="tabler:lock" />
					<span>You already own this FLOAT</span>
				</div>
			</div>
		{:else if secretCode || requireEmail}
			{#if powerUpErrorMessage}
				<div
					class="secret-code-message"
					class:alert={powerUpErrorMessage !== 'Unlocked'}
					class:success={powerUpErrorMessage === 'Unlocked'}
				>
					<div class="row-1 align-center justify-center" in:fly={{ duration: 300, y: -10 }}>
						<Icon icon={powerUpErrorMessage !== 'Unlocked' ? 'tabler:lock' : 'tabler:lock-open'} />
						<span>{powerUpErrorMessage}</span>
					</div>
				</div>
			{/if}
			{#if secretCode}
				<div class="input-wrapper">
					<input
						type="password"
						placeholder="Insert secret code"
						max="60"
						bind:value={secretCodeInputValue}
					/>
				</div>
			{/if}
			{#if requireEmail}
				<div class="input-wrapper">
					<input placeholder="Insert email" max="60" bind:value={requireEmailInputValue} />
				</div>
			{/if}
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
			{#if !$user.loggedIn || (floatAlreadyClaimed && !event.multipleClaim) || !event.claimable}
				<Button size="large" width="full-width" state="disabled">Claim FLOAT</Button>
			{:else if secretCode || requireEmail}
				<Button
					size="large"
					width="full-width"
					state={(!secretCode || secretCodeInputValue.length > 0) &&
					(!requireEmail || requireEmailInputValue.length > 0)
						? 'active'
						: 'disabled'}
					on:click={() => handleClaimFloat()}
				>
					Claim FLOAT
				</Button>
			{:else}
				<Button size="large" width="full-width" on:click={() => handleClaimFloat()}>
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
			background-color: var(--clr-surface-secondary);
			padding: var(--space-1);
			color: var(--clr-text-off);
			border-top: 1px solid var(--clr-neutral-badge);

			@include mq(small) {
				background-color: transparent;
				border-top: none;
				padding: 0px;
			}

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