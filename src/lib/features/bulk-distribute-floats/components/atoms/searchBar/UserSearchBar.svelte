<script lang="ts">
	import { fly, fade } from 'svelte/transition';
	import validationSuite from './validation';
	import type { SuiteRunResult } from 'vest';
	import Profile from '$lib/components/floats/atoms/Profile/Profile.svelte';
	import Icon from '@iconify/svelte';

	export let addressInputValue: string;
	export let customError: string = '';

	const handleChange = (input: Event) => {
		const target = input.target as HTMLInputElement;
		res = validationSuite(target.value);

		(res as SuiteRunResult).done((result) => {
			res = result;
		});
	};

	let res = validationSuite.get();

	$: validUser = res.isValid() && addressInputValue.length > 0;
	$: canBeAddress = addressInputValue.length === 18 && addressInputValue.startsWith('0x');
</script>

<div
	class="main-wrapper"
	class:valid={validUser}
	class:invalid={(!validUser && canBeAddress) || customError}
>
	<div class="input-wrapper">
		<input
			name="address"
			type="text"
			maxlength="18"
			placeholder="Type a Flow address or .find name"
			on:input={handleChange}
			bind:value={addressInputValue}
		/>
		{#if validUser && !customError}
			<button class="row-1 align-center" transition:fade|locale={{ duration: 300 }}>
				Add <Icon icon="tabler:arrow-right" />
			</button>
		{/if}
	</div>
	{#if validUser || canBeAddress}
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

		&.valid {
			background-color: var(--clr-primary-badge);
			border-bottom-left-radius: var(--radius-2);
			border-bottom-right-radius: var(--radius-2);

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

		.input-wrapper {
			position: relative;

			input {
				border: 1px solid var(--clr-border-primary);
				width: 100%;
				font-size: var(--font-size-2);
				padding: var(--space-4);

				&::placeholder {
					color: var(--clr-text-off);
				}
			}

			button {
				position: absolute;
				right: 5%;
				top: 50%;
				transform: translateY(-50%);
				background-color: transparent;
				border: none;
				cursor: pointer;
				color: var(--clr-primary-main);
			}
		}

		.profile-wrapper {
			padding: var(--space-4);
		}
	}
</style>
