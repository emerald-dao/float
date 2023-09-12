<script lang="ts">
	import Filters from '$lib/components/filters/Filters.svelte';
	import { InputWrapper } from '@emerald-dao/component-library';
	import { onDestroy, onMount } from 'svelte';
	import type { Filter } from '$lib/types/content/filters/filter.interface';
	import { createSearchStore, searchHandler } from '$lib/stores/searchBar';
	import { createFilters } from '../../_functions/filters';
	import { filterEventsContent } from '../../_functions/filterEventsContent';
	import { unixTimestampToFormattedDate } from '$lib/utilities/dates/unixTimestampToFormattedDate';
	import IntersectionObserver from 'svelte-intersection-observer';
	import type { EventWithStatus } from '$lib/types/event/event.interface';
	import EventCard from '$lib/components/events/EventCard.svelte';

	export let events: EventWithStatus[];
	export let viewMode: 'cards' | 'tickets';

	let filters: Filter[] = [];

	let activeFilters = {
		typeOfEvent: true
	};

	onMount(() => {
		filters = createFilters(activeFilters);
	});

	$: searchEvent = events.map((event) => ({
		...event,

		searchTerms: `${event.name}`
	}));

	$: searchStore = createSearchStore(searchEvent);

	$: unsubscribe = searchStore.subscribe((model) => searchHandler(model));

	onDestroy(() => {
		unsubscribe();
	});

	let filteredContent: Promise<EventWithStatus[]> | EventWithStatus[];

	$: if (filters.length > 0 && $searchStore.search.length > 0) {
		filteredContent = filterEventsContent(filters, $searchStore.filtered, activeFilters);
	} else if (filters.length > 0) {
		filteredContent = filterEventsContent(filters, events, activeFilters);
	} else if ($searchStore.search.length > 0) {
		filteredContent = $searchStore.filtered;
	} else {
		filteredContent = events;
	}

	// Infinite scroll feature
	let intersectionObserverElement: HTMLDivElement;
	let intersecting: boolean;

	let elementsPerPage = 10;

	$: if (intersecting && elementsPerPage < events.length) elementsPerPage += 10;
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
	</div>
	<div class="rightside" class:list={viewMode === 'cards'}>
		{#await filteredContent then contents}
			{#if contents.length > 0}
				{#each contents as event, i}
					{#if i < elementsPerPage}
						<div class="float-wrapper grid">
							<div class="timeline" class:last={contents.length - 1 === i} class:first={i === 0}>
								<div class="line" />
								<div class="date-wrapper">
									<p class="small">
										{unixTimestampToFormattedDate(event.dateCreated, 'month')}
									</p>
									<p class="large w-medium">
										{unixTimestampToFormattedDate(event.dateCreated, 'year')}
									</p>
								</div>
								<div class="line" />
							</div>
							{#if viewMode === 'tickets'}
								<div class="ticket-wrapper">
									<EventCard {event} display="grid" displayedInAdmin={false} />
								</div>
							{:else if viewMode === 'cards'}
								<div class="card-wrapper">
									<EventCard {event} display="list" displayedInAdmin={false} />
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
				<span><em>No events found</em></span>
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
					padding-block: var(--space-6);
				}
			}
		}
	}

	.intersection-element {
		height: 1px;
		width: 1px;
	}
</style>
