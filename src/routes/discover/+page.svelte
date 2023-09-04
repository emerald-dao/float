<script lang="ts">
	import { Button } from '@emerald-dao/component-library';
	import validateUserExistance from './_actions/validateUserExistance.js';
	import Icon from '@iconify/svelte';
	import { fly } from 'svelte/transition';
	import TrendingEvents from './_components/TrendingEvents.svelte';

	export let data;

	let userValidation: boolean;
	let inputValue: string;

	const handleSubmit = async (value: string) => {
		userValidation = await validateUserExistance(value);

		if (userValidation) {
			// Add the user wallet address after the "/"
			window.location.href = 'u/';
		}
	};
</script>

<div class="container-large">
	<section class="top-wrapper">
		<h1 class="w-bold">Discover</h1>
		<div class="input-message">
			{#if userValidation === false}
				<div
					class="row-1 align-center justify-center"
					class:alert={!userValidation}
					in:fly={{ duration: 300, y: -10 }}
				>
					<Icon icon="tabler:lock" />
					<span>User doesn't exist</span>
				</div>
			{:else}
				<div class="row-1 align-center justify-center" in:fly={{ duration: 300, y: -10 }}>
					<Icon icon="tabler:info-circle" />
					<span>Search users by name or wallet address</span>
				</div>
			{/if}
		</div>
		<div class="row-1">
			<input type="text" placeholder="Search for users profiles..." bind:value={inputValue} />
			<Button width="full-width" on:click={() => handleSubmit(inputValue)}><p>Visit user</p></Button
			>
		</div>
	</section>
	<TrendingEvents events={data.events} />
</div>

<style lang="scss">
	.container-large {
		display: flex;
		flex-direction: column;
		justify-content: center;
		align-items: center;
		padding-bottom: var(--space-14);

		.top-wrapper {
			display: flex;
			flex-direction: column;
			align-items: center;
			justify-content: center;

			h1 {
				padding-bottom: var(--space-5);
			}

			input {
				min-width: 250px;
			}

			.input-message {
				justify-content: center;
				align-items: center;
				font-size: var(--font-size-1);
				padding-left: var(--space-2);

				.alert {
					color: var(--clr-alert-main);
				}
			}
		}
	}
</style>
