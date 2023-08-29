<script lang="ts">
	import Filters from '$lib/components/filters/Filters.svelte';
	import { InputWrapper } from '@emerald-dao/component-library';
	import { onDestroy, onMount } from 'svelte';
	import type { Filter } from '$lib/types/content/filters/filter.interface';
	import { createSearchStore, searchHandler } from '$lib/stores/searchBar';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import { createFilters } from '../../_functions/filters';
	import { filterFloatsContent } from '../../_functions/filterFloatsContent';
	import { unixTimestampToFormattedDate } from '$lib/utilities/dates/unixTimestampToFormattedDate';
	import IntersectionObserver from 'svelte-intersection-observer';
	import type { GroupWithFloatsIds } from '$lib/features/groups/types/group.interface';
	import GroupsToggles from '../atoms/GroupsToggles.svelte';
	import FloatCard from '../../../admin/[userAddress]/my-collection/_components/FloatCard/FloatCard.svelte';
	import Float from '$lib/components/floats/Float.svelte';

	export let floats: FLOAT[];
	export let groups: GroupWithFloatsIds[];
	export let viewMode: 'cards' | 'tickets';

	let selectedGroupsIds: number[] = [];
	let activeGroupsFloats: FLOAT[] = [];

	// Filter floats if selectedGroupsIds is not null
	$: if (selectedGroupsIds.length > 0) {
		const allActiveFloatsIds = selectedGroupsIds.map((id) => {
			const group = groups.find((group) => group.id === id);

			if (group) {
				return group.floatsIds;
			} else {
				return [];
			}
		});

		activeGroupsFloats = floats.filter((float) => {
			const floatId = float.id;
			return allActiveFloatsIds.some((ids) => ids.includes(floatId));
		});
	} else {
		activeGroupsFloats = floats;
	}

	let filters: Filter[] = [];

	let activeFilters = {
		typeOfEvent: true
	};

	onMount(() => {
		filters = createFilters(activeFilters);
	});

	$: searchFloat = floats.map((float) => ({
		...float,

		searchTerms: `${float.eventName}`
	}));

	$: searchStore = createSearchStore(searchFloat);

	$: unsubscribe = searchStore.subscribe((model) => searchHandler(model));

	onDestroy(() => {
		unsubscribe();
	});

	let filteredContent: Promise<FLOAT[]> | FLOAT[];

	$: if (filters.length > 0 && $searchStore.search.length > 0) {
		filteredContent = filterFloatsContent(filters, $searchStore.filtered, activeFilters);
	} else if (filters.length > 0) {
		filteredContent = filterFloatsContent(filters, activeGroupsFloats, activeFilters);
	} else if ($searchStore.search.length > 0) {
		filteredContent = $searchStore.filtered;
	} else {
		filteredContent = activeGroupsFloats;
	}

	// Infinite scroll feature
	let intersectionObserverElement: HTMLDivElement;
	let intersecting: boolean;

	let elementsPerPage = 10;

	$: if (intersecting && elementsPerPage < activeGroupsFloats.length) elementsPerPage += 10;
</script>

<div class="content-wrapper">
	<div class="leftside">
		<div class="search-wrapper">
			<h5>Search</h5>
			<InputWrapper name="search" errors={[]} isValid={false}>
				<input type="text" placeholder="Search by title..." bind:value={$searchStore.search} />
			</InputWrapper>
		</div>
		<div class="filters-wrapper">
			<h5>Filters</h5>
			<Filters bind:filters />
		</div>
		<div class="groups-wrapper">
			<h5>Groups</h5>
			<GroupsToggles {groups} bind:selectedGroupsIds />
		</div>
	</div>
	<div class="rightside">
		{#await filteredContent then contents}
			{#if contents.length > 0}
				{#each contents as float, i}
					{#if i < elementsPerPage}
						<div class="float-wrapper" class:grid={viewMode === 'tickets'}>
							{#if viewMode === 'tickets'}
								<div class="timeline" class:last={contents.length - 1 === i} class:first={i === 0}>
									<div class="line" />
									<div class="date-wrapper">
										<p class="small">
											{unixTimestampToFormattedDate(float.dateReceived, 'month')}
										</p>
										<p class="large w-medium">
											{unixTimestampToFormattedDate(float.dateReceived, 'year')}
										</p>
									</div>
									<div class="line" />
								</div>
							{/if}
							{#if viewMode === 'tickets'}
								<div class="ticket-wrapper">
									<Float {float} />
								</div>
							{:else if viewMode === 'cards'}
								<div class="card-wrapper">
									<FloatCard {float} hasLink={false} />
								</div>
							{/if}
						</div>
					{/if}
				{/each}
				{#if contents.length > elementsPerPage}
					<IntersectionObserver element={intersectionObserverElement} bind:intersecting>
						<div bind:this={intersectionObserverElement} class="intersection-element" />
					</IntersectionObserver>
				{/if}
			{:else}
				<span><em>No FLOATs found</em></span>
			{/if}
		{/await}
	</div>
</div>

<style lang="scss">
	.content-wrapper {
		display: flex;
		flex-direction: column;
		gap: var(--space-5);
		margin-top: var(--space-12);

		h5 {
			margin: 0;
			font-size: var(--font-size-4);
		}

		@include mq(medium) {
			display: grid;
			grid-template-columns: 1fr 2fr;
			gap: var(--space-10);
		}

		.leftside {
			display: flex;
			flex-direction: column;
			gap: var(--space-4);
			border-bottom: 0.5px var(--clr-neutral-primary) solid;
			height: fit-content;
			padding-bottom: var(--space-4);

			@include mq(medium) {
				gap: var(--space-7);
				border-bottom: none;
				position: sticky;
				top: 140px;
			}

			.filters-wrapper,
			.groups-wrapper,
			.search-wrapper {
				display: none;
				padding-bottom: 2rem;
				border-bottom: 1px dashed var(--clr-border-primary);

				@include mq(small) {
					display: flex;
					flex-direction: column;
					gap: var(--space-3);
				}

				@include mq(medium) {
					gap: var(--space-4);
				}
			}
		}

		.rightside {
			display: flex;
			flex-direction: column;
			justify-content: flex-start;
			align-items: center;

			.float-wrapper {
				display: flex;
				flex-direction: column;
				justify-content: center;
				width: 100%;

				&.grid {
					@include mq(small) {
						display: grid;
						grid-template-columns: 1fr 3fr;
					}
				}

				.timeline {
					display: flex;
					flex-direction: column;
					align-items: center;

					&.first {
						.line:first-child {
							border-image: linear-gradient(transparent, var(--clr-primary-badge)) 30;
						}
					}

					&.last {
						.line:last-child {
							border-image: linear-gradient(var(--clr-primary-badge), transparent) 30;
						}
					}

					.line {
						@include mq(small) {
							flex: 1;
							border: 1.5px solid var(--clr-primary-badge);
						}
					}

					.date-wrapper {
						background-color: var(--clr-primary-badge);
						border-radius: var(--radius-2);
						padding: var(--space-4);
						text-align: center;
						border: 1px solid var(--clr-primary-badge);

						p {
							color: var(--clr-primary-main);
						}
					}
				}

				.ticket-wrapper {
					width: 100%;
					display: flex;
					padding-block: var(--space-10);
				}

				.card-wrapper {
					width: 100%;
					padding-block: var(--space-3);
					padding-left: var(--space-14);
				}
			}
		}
	}

	.intersection-element {
		height: 1px;
		width: 1px;
	}
</style>
