<script lang="ts">
	import { fly } from 'svelte/transition';
	import FloatCard from './_components/FloatCard.svelte';
	import { createSearchStore, searchHandler } from '$stores/searchBar';
	import { onDestroy, onMount, setContext } from 'svelte';
	import { page } from '$app/stores';
	import Pagination from '$lib/components/atoms/Pagination.svelte';

	export let data;

	let paginationMax: number;
	let paginationMin: number;

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
				<p class="small off">{$searchStore.filtered.length} FLOATs</p>
			</div>
			<input type="text" placeholder="Search event name or id" bind:value={$searchStore.search} />
		</div>
		<Pagination
			itemsPerPage={10}
			totalItems={$searchStore.filtered.length}
			noItemsMessage="No results found"
			bind:paginationMax
			bind:paginationMin
		>
			<div class="bottom-wrapper">
				{#each $searchStore.filtered as float, i}
					{#if i < paginationMax && i >= paginationMin}
						<FloatCard {float} />
					{/if}
				{/each}
			</div>
		</Pagination>
	</div>
	<div class="right-wrapper">
		<slot />
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		display: block;

		@include mq(medium) {
			display: grid;
			grid-template-columns: 1.1fr 1fr;
			justify-content: center;
			flex: 1;
			min-height: 1px;
			max-height: 100%;
			overflow-y: hidden;
		}

		.left-wrapper {
			display: flex;
			flex-direction: column;

			@include mq(medium) {
				flex: 1;
				min-height: 100%;
				max-height: 100%;
				border-right: 0.5px solid var(--clr-border-primary);
				box-shadow: 20px 0px 15px -22px var(--clr-shadow-primary);
				z-index: 1;
			}

			.top-wrapper {
				display: flex;
				flex-direction: column;
				gap: var(--space-4);
				justify-content: center;
				padding-bottom: var(--space-5);
				border-bottom: 0.5px solid var(--clr-border-primary);
				background-color: var(--clr-background-primary);

				.title-wrapper {
					display: flex;
					justify-content: space-between;
					align-items: flex-end;

					h5 {
						margin: 0;
						font-size: var(--font-size-4);
					}

					.off {
						color: var(--clr-text-off);
					}
				}
			}

			.bottom-wrapper {
				display: flex;
				flex-direction: column;
				gap: var(--space-5);

				@include mq(small) {
					overflow-y: auto;
				}
			}

			.top-wrapper,
			.bottom-wrapper {
				padding: var(--space-6) var(--space-6);

				@include mq(small) {
					padding: var(--space-6) var(--space-8);
				}
			}
		}

		.right-wrapper {
			display: none;

			@include mq(medium) {
				display: block;
				background-color: var(--clr-background-secondary);
			}
		}
	}
</style>
