<script lang="ts">
	import { clickOutside } from '$lib/utilities/clickOutside';
	import { fly, fade } from 'svelte/transition';
	import validationSuite from './validation';
	import type { SuiteRunResult } from 'vest';
	import Profile from '$lib/components/floats/atoms/Profile/Profile.svelte';
	import Icon from '@iconify/svelte';
	import { onMount } from 'svelte';
	import KeyBoardShortcutSign from '$lib/components/atoms/KeyBoardShortcutSign.svelte';

	export let addressInputValue: string = '';
	export let customError: string = '';
	export let buttonText = 'Add';
	export let fontSize = '1rem';
	export let autoSelectKey: string | null = null;
	export let placeholder = 'Type a Flow address or .find name';
	export let dropdownMode = false;
	export let autoFocus = false;

	export let validUser: boolean = false;

	let showDropdown = false;

	let addressInputElement: HTMLInputElement;
	let isFocus: boolean;

	// When user clicks the autoSelectKey, select the input text
	const handleKeyDown = (event: KeyboardEvent) => {
		const formElements = ['INPUT', 'TEXTAREA', 'SELECT', 'OPTION'];

		if (event.key === autoSelectKey && !formElements.includes(event.target?.tagName)) {
			event.preventDefault();
			addressInputElement.select();
		}
	};

	const handleChange = (input: Event) => {
		const target = input.target as HTMLInputElement;

		res = validationSuite(target.value);

		(res as SuiteRunResult).done((result) => {
			res = result;
		});
	};

	// Autofocus input when it appears on the screen
	onMount(() => {
		if (autoFocus) {
			addressInputElement.focus();
		}
	});

	let res = validationSuite.get();

	$: validUser = res.isValid() && addressInputValue.length > 0;
	$: canBeAddress = addressInputValue.length === 18 && addressInputValue.startsWith('0x');

	$: if (validUser) {
		showDropdown = true;
	} else {
		showDropdown = false;
	}
</script>

<svelte:window on:keydown={handleKeyDown} />
<div
	class="main-wrapper"
	class:valid={validUser}
	class:invalid={(!validUser && canBeAddress) || customError}
	style={`font-size: ${fontSize}`}
	use:clickOutside={() => {
		if (dropdownMode) {
			showDropdown = false;
		}
	}}
>
	<div class="input-wrapper row-1 align-center">
		{#if autoSelectKey}
			<div class="keyboard-shortcut">
				<KeyBoardShortcutSign
					symbol={validUser && isFocus ? '↩︎' : autoSelectKey}
					fontSize="0.8rem"
				/>
			</div>
		{/if}
		<input
			name="address"
			type="text"
			maxlength="18"
			autocomplete="off"
			{placeholder}
			on:input={handleChange}
			on:focus={() => (isFocus = true)}
			on:blur={() => (isFocus = false)}
			bind:value={addressInputValue}
			bind:this={addressInputElement}
			class:alert-border={res.hasErrors()}
			class:has-shortcut={autoSelectKey}
		/>
		{#if validUser && !customError}
			<button class="row-1 align-center" transition:fade|locale={{ duration: 300 }}>
				{buttonText}
				<Icon icon="tabler:arrow-right" />
			</button>
		{/if}
	</div>
	{#if showDropdown}
		<div class="profile-wrapper" transition:fly|locale={{ y: -5, duration: 400 }}>
			<Profile address={addressInputValue} size="1.2rem" />
			{#if (!validUser && canBeAddress) || customError}
				<span class="error xsmall row-1 align-center">
					<Icon icon="tabler:x" />
					<span
						>{customError.length > 0
							? customError
							: `Address doesn't have a FLOAT collection setup`}</span
					>
				</span>
			{/if}
		</div>
	{/if}
</div>

<style lang="scss">
	.main-wrapper {
		border-top-left-radius: var(--radius-2);
		border-top-right-radius: var(--radius-2);
		overflow: visible;
		width: 100%;
		position: relative;

		.input-wrapper {
			position: relative;
			height: 100%;

			.keyboard-shortcut {
				position: absolute;
				left: 2%;
				top: 50%;
				transform: translateY(-50%);
			}

			input {
				border: 1px solid var(--clr-border-primary);
				width: 100%;
				font-size: 0.9em;
				transition: 400ms;
				width: 100%;

				&::placeholder {
					color: var(--clr-text-off);
					opacity: 0.7;
				}

				&:focus {
					border-color: var(--clr-text-main);
					background-color: var(--clr-surface-secondary);
					box-shadow: 1px 4px 12px -2px var(--clr-shadow-primary);
				}

				&.alert-border {
					&:focus {
						border-color: var(--clr-alert-main);
					}
				}

				&.has-shortcut {
					padding-left: 2.6em;
				}
			}

			button {
				position: absolute;
				right: 3%;
				top: 50%;
				transform: translateY(-50%);
				background-color: transparent;
				border: none;
				cursor: pointer;
				color: var(--clr-primary-main);
				font-size: 0.9em;
			}
		}

		.profile-wrapper {
			width: 100%;
			padding: var(--space-4);
			position: absolute;
			display: inline-block;
			background-color: var(--clr-surface-secondary);
			border-bottom-left-radius: var(--radius-2);
			border-bottom-right-radius: var(--radius-2);
			box-shadow: 3px 4px 10px -4px var(--clr-shadow-primary);
			z-index: 99999;
		}

		&.valid {
			background-color: var(--clr-surface-secondary);

			.input-wrapper {
				input {
					border-color: var(--clr-primary-main);
				}
			}
		}

		&.invalid {
			background-color: var(--clr-alert-badge);
			border-bottom-left-radius: var(--radius-2);
			border-bottom-right-radius: var(--radius-2);

			.input-wrapper {
				input {
					border-color: var(--clr-alert-main);
				}
			}

			.error {
				color: var(--clr-alert-main);
				margin-top: var(--space-2);
			}
		}
	}
</style>
