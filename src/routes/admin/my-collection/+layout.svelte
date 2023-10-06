<script lang="ts">
	import { user } from '$lib/stores/flow/FlowStore';
	import { fly } from 'svelte/transition';
	import FloatCard from './_components/FloatCard/FloatCard.svelte';
	import { createSearchStore, searchHandler } from '$stores/searchBar';
	import { onDestroy, onMount, setContext } from 'svelte';
	import Pagination from '$lib/components/atoms/Pagination.svelte';
	import { goto } from '$app/navigation';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import { getFLOATs } from '$flow/actions';
	import createFetchStore from '../_stores/fetchStore';
	import PinFloatIcon from './_components/atoms/PinFloatIcon.svelte';

	let floats = createFetchStore<FLOAT[]>(() => getFLOATs($user.addr as string), []);

	setContext('floats', floats);

	let pinnedFloats = createFetchStore<string[]>(
		() => fetch(`/api/pinned-floats/${$user.addr}`).then((res) => res.json()),
		[]
	);

	setContext('pinnedFloats', pinnedFloats);

	let loadingFloats = false;

	let paginationMax: number;
	let paginationMin: number;

	$: searchEvent = $floats.map((example) => ({
		...example,

		searchTerms: `${example.eventName} ${example.id}`
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
			{#if loadingFloats}
				<div class="center">
					<em>Loading FLOATs</em>
				</div>
			{:else if $searchStore.filtered.length === 0}
				<div class="center">
					<em>No FLOATs found</em>
				</div>
			{:else}
				{#each $searchStore.filtered as float, i}
					{#if i < paginationMax && i >= paginationMin}
						<div class="row-5 align-center">
							<FloatCard {float} />
							<div class="pin-icon-wrapper">
								<PinFloatIcon {float} />
							</div>
						</div>
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
		{#if loadingFloats}
			<div class="center">
				<em>Loading FLOATs</em>
			</div>
		{:else}
			<slot />
		{/if}
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
				height: 100%;

				@include mq(small) {
					overflow-y: auto;
				}

				.pin-icon-wrapper {
					display: none;

					@include mq(small) {
						display: flex;
						justify-content: center;
						align-items: center;
					}
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
					padding: var(--space-6) var(--space-7);
				}
			}
		}

		.right-wrapper {
			display: none;

			@include mq(medium) {
				display: block;
				position: relative;
				background-color: var(--clr-background-secondary);
				overflow: hidden;
			}
		}
	}
</style>
