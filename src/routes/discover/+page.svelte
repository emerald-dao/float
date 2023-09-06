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

<section
	class="section-large"
	style={`background-image: linear-gradient(
    rgba(250, 250, 250, 0.87),
		rgba(250, 250, 250, 0.91),
    rgba(250, 250, 250, 1)
  ), url("/badges/each-event-type-floats/level-3.png")`}
>
	<div class="container-large">
		<h1 class="w-medium">Discover</h1>
		<div class="search-bar-and-message-wrapper column-1 justify-center align-center">
			<div class="input-message">
				{#if userValidation === false}
					<div
						class="row-1 align-center justify-center"
						class:alert={!userValidation}
						in:fly={{ duration: 300, y: -10 }}
					>
						<Icon icon="tabler:lock" />
						<span class="small">User doesn't exist</span>
					</div>
				{/if}
			</div>
			<form class="search-bar-wrapper row-1">
				<input type="text" placeholder="Type address or .find name" bind:value={inputValue} />
				<Button width="extended" size="small" on:click={() => handleSubmit(inputValue)}>
					Go
					<Icon icon="tabler:arrow-right" />
				</Button>
			</form>
		</div>
	</div>
</section>
<section class="container-medium">
	<TrendingEvents events={data.events} />
</section>

<style lang="scss">
	.container-large {
		display: flex;
		flex-direction: column;
		justify-content: center;
		align-items: center;
		gap: var(--space-6);

		.search-bar-and-message-wrapper {
			width: 100%;

			.search-bar-wrapper {
				width: 100%;
				display: flex;
				justify-content: center;

				input {
					max-width: 250px;
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
	}
</style>
