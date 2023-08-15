<script lang="ts">
	import { page } from '$app/stores';
	import { fly } from 'svelte/transition';
	import FloatCard from './_components/FloatCard/FloatCard.svelte';
	import { createSearchStore, searchHandler } from '$stores/searchBar';
	import { onDestroy, onMount, setContext } from 'svelte';
	import Pagination from '$lib/components/atoms/Pagination.svelte';
	import { goto } from '$app/navigation';

	export let data;

	let paginationMax: number;
	let paginationMin: number;

	setContext('floats', data.floats);

	onMount(() => {
		if (data.floats[0] && data.floats[0].eventId) {
			goto(`/admin/${$page.params.userAddress}/my-collection/${data.floats[0].eventId}`);
		}
	});

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
		<div class="bottom-wrapper">
			{#if $searchStore.filtered.length === 0}
				<div class="center">
					<em>No FLOATs found</em>
				</div>
			{:else}
				{#each $searchStore.filtered as float, i}
					{#if i < paginationMax && i >= paginationMin}
						<FloatCard {float} />
					{/if}
				{/each}
			{/if}
		</div>
		{#if $searchStore.filtered.length !== 0}
			<div class="pagination">
				<Pagination
					itemsPerPage={10}
					totalItems={$searchStore.filtered.length}
					bind:paginationMax
					bind:paginationMin
				/>
			</div>
		{/if}
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
				box-shadow: 0px 0px 10px 0px var(--clr-shadow-primary);

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

			.pagination {
				border-top: 0.5px solid var(--clr-border-primary);
			}

			.top-wrapper,
			.bottom-wrapper,
			.pagination {
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
