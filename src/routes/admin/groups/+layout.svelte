<script lang="ts">
	import { fly } from 'svelte/transition';
	import { createSearchStore, searchHandler } from '$stores/searchBar';
	import { onDestroy } from 'svelte';
	import Pagination from '$lib/components/atoms/Pagination.svelte';
	import GroupCard from './_components/GroupCard.svelte';
	import { Button } from '@emerald-dao/component-library';
	import ItemsListWrapper from '$lib/components/atoms/ItemsListWrapper.svelte';

	export let data;

	let paginationMax: number;
	let paginationMin: number;

	$: searchEvent = data.groups.map((example) => ({
		group: example,
		searchTerms: `${example.name} ${example.id}`
	}));

	$: searchStore = createSearchStore(searchEvent);

	$: unsubscribe = searchStore.subscribe((model) => searchHandler(model));

	onDestroy(() => {
		unsubscribe();
	});
</script>

<div class="main-wrapper" in:fly={{ x: 10, duration: 400 }}>
	<div class="left-wrapper">
		<div class="content-wrapper">
			<div class="top-wrapper">
				<div class="title-wrapper">
					<h5>My Groups</h5>
					<p class="small off">{$searchStore.filtered.length} groups</p>
				</div>
				<input type="text" placeholder="Search group name or id" bind:value={$searchStore.search} />
			</div>
			<div class="bottom-wrapper">
				<ItemsListWrapper
					numberOfItems={$searchStore.filtered.length}
					noItemsMessage="You don't have any group yet"
				>
					<div class="groups-wrapper">
						{#each $searchStore.filtered as group, i}
							{#if i < paginationMax && i >= paginationMin}
								<GroupCard group={group.group} />
							{/if}
						{/each}
					</div>
				</ItemsListWrapper>
			</div>
		</div>
		<div class="pagination-wrapper row-space-between row-6">
			<Pagination
				itemsPerPage={10}
				totalItems={$searchStore.filtered.length}
				noItemsMessage="No results found"
				bind:paginationMax
				bind:paginationMin
			/>
			<Button href="/admin/groups/new-group" type="ghost" color="neutral" size="x-small">
				Add new group
			</Button>
		</div>
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
			border-right: 0.5px solid var(--clr-border-primary);
			box-shadow: 20px 0px 15px -22px var(--clr-shadow-primary);
			z-index: 1;
			overflow-y: hidden;

			.content-wrapper {
				overflow-y: hidden;
				display: flex;
				flex-direction: column;
				height: 100%;

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
					height: 100%;
					overflow-y: hidden;

					.groups-wrapper {
						overflow-y: auto;
						display: flex;
						flex-direction: column;
						gap: var(--space-5);
						height: 100%;
					}
				}
			}

			.pagination-wrapper {
				border-top: 0.5px solid var(--clr-border-primary);
				height: fit-content;
			}

			.top-wrapper,
			.groups-wrapper,
			.pagination-wrapper {
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
				overflow-y: hidden;
			}
		}
	}
</style>
