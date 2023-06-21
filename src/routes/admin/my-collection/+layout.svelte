<script type="ts">
	import { fly } from 'svelte/transition';
	import { Button } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';
	import FloatSmallTicket from '$lib/components/floats/FloatSmallTicket.svelte';
	import { createSearchStore, searchHandler } from '$stores/searchBar';
	import { onDestroy, setContext } from 'svelte';

	export let data;

	setContext('floats', data.floats);

	$: searchEvent = data.floats.map((example) => ({
		...example,

		searchTerms: `${example.eventName} ${example.eventId}`
	}));

	$: searchStore = createSearchStore(searchEvent);

	$: unsubscribe = searchStore.subscribe((model) => searchHandler(model));

	onDestroy(() => {
		unsubscribe();
	});
</script>

<div class="main-wrapper" in:fly={{ x: 10, duration: 400 }}>
	<div class="left-wrapper">
		<div class="top-wrapper">
			<div class="title-wrapper">
				<h5>My Collection</h5>
				<p class="medium">41 FLOATs</p>
			</div>
			<div class="input-wrapper">
				<input type="text" placeholder="Search event name or id" bind:value={$searchStore.search} />
				<div class="button-wrapper">
					<Button type="transparent">
						<Icon icon="tabler:arrows-sort" color="var(--clr-text-main)" />
					</Button>
				</div>
			</div>
		</div>
		<div class="bottom-wrapper">
			{#if $searchStore.search.length > 0 && $searchStore.filtered.length === 0}
				<p>No results found</p>
			{:else}
				{#each $searchStore.filtered as float}
					<FloatSmallTicket {float} />
				{/each}
			{/if}
		</div>
	</div>
	<div class="right-wrapper">
		<slot />
	</div>
</div>

<style type="scss">
	.main-wrapper {
		display: grid;
		grid-template-columns: 2fr 3fr;
		justify-content: center;
		gap: var(--space-4);

		.left-wrapper {
			display: flex;
			flex-direction: column;
			gap: var(--space-9);
			padding: var(--space-6) var(--space-2);

			.top-wrapper {
				display: flex;
				flex-direction: column;
				gap: var(--space-4);
				justify-content: center;
				padding-bottom: var(--space-3);
				border-bottom: var(--border-width-primary) solid var(--clr-border-primary);

				.title-wrapper {
					display: flex;
					justify-content: space-between;
					align-items: center;

					h5 {
						margin: 0;
					}
				}

				.input-wrapper {
					display: grid;
					grid-template-columns: 3fr 1fr;
					justify-content: space-between;

					.button-wrapper {
						display: flex;
						justify-content: flex-end;
					}
				}
			}

			.bottom-wrapper {
				display: flex;
				flex-direction: column;
				gap: var(--space-5);
			}
		}

		.right-wrapper {
			background-color: var(--clr-background-secondary);
		}
	}
</style>