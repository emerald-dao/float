<script type="ts">
	import Filters from '$lib/components/filters/Filters.svelte';
	import { InputWrapper, ProgressSteps } from '@emerald-dao/component-library';
	import { onDestroy, onMount } from 'svelte';
	import type { Filter } from '$lib/types/content/filters/filter.interface';
	import { filterContent } from '../../functions/filterContent';
	import { createFilters } from '../../functions/filters';
	import type { Event } from '$lib/types/event/event.interface';
	import type { ProgressStates } from '@emerald-dao/component-library/components/ProgressStep/progress-states.type';
	import FloatTicket from '$lib/components/floats/FloatTicket.svelte';
	import { generatedNft } from '$lib/features/event-generator/stores/EventGeneratorData';
	import Badges from '../atoms/Badges.svelte';
	import { createSearchStore, searchHandler } from '../../../../stores/searchBar';

	export let contentList: Event[];
	export let typeOfEventFilter = true;

	let filters: Filter[] = [];

	let activeFilters = {
		typeOfEvent: typeOfEventFilter
	};

	onMount(() => {
		filters = createFilters(activeFilters);
	});

	$: searchCadence = contentList.map((example) => ({
		...example,

		searchTerms: `${example.name}`
	}));

	$: searchStore = createSearchStore(searchCadence);

	$: unsubscribe = searchStore.subscribe((model) => searchHandler(model));

	onDestroy(() => {
		unsubscribe();
	});

	let filteredContent: Promise<Event[]> | Event[];

	$: if (filters.length > 0 && $searchStore.search.length > 0) {
		filteredContent = filterContent(filters, $searchStore.filtered, activeFilters);
	} else if (filters.length > 0) {
		filteredContent = filterContent(filters, contentList, activeFilters);
	} else if ($searchStore.search.length > 0) {
		filteredContent = $searchStore.filtered;
	} else {
		filteredContent = contentList;
	}

	let steps: Step[] = [];
	let badges: BadgesInterface[] = [];

	interface Step {
		name: string;
		state: ProgressStates;
	}

	interface BadgesInterface {
		icon: string;
		name: string;
	}

	steps = [
		{
			name: '2020',
			state: 'inactive'
		},
		{
			name: '2021',
			state: 'inactive'
		},
		{
			name: '2022',
			state: 'inactive'
		},
		{
			name: '2023',
			state: 'inactive'
		}
	];

	badges = [
		{
			icon: 'tabler:brand-discord',
			name: 'Discord Geek'
		},
		{
			icon: 'tabler:brand-twitter',
			name: 'Twitter Worm'
		},
		{
			icon: 'tabler:brand-discord',
			name: 'Discord Geek'
		},
		{
			icon: 'tabler:brand-twitter',
			name: 'Twitter Worm'
		},
		{
			icon: 'tabler:brand-discord',
			name: 'Discord Geek'
		}
	];
</script>

<div class="content-wrapper">
	<div class="leftside">
		<h5>Search</h5>
		<div>
			<InputWrapper name="search" errors={[]} isValid={false} icon="tabler:search">
				<input type="text" placeholder="Search by title..." bind:value={$searchStore.search} />
			</InputWrapper>
		</div>
		<h5>Filters</h5>
		<Filters bind:filters />
		<h5>Badges</h5>
		<Badges {badges} />
	</div>
	<div class="rightside">
		{#await filteredContent then contents}
			{#if contents.length > 0}
				{#each contents as content}
					<div class="main-wrapper">
						<div class="timeline">
							<div class="line" />
							<div class="date-wrapper">
								<p class="small">February</p>
								<p class="large w-medium">2023</p>
							</div>
							<div class="line" />
						</div>
						<div class="tickets">
							<FloatTicket float={$generatedNft} />
						</div>
					</div>
				{/each}
			{:else}
				<span><em>No content found</em></span>
			{/if}
		{/await}
	</div>
</div>

<style type="scss">
	.content-wrapper {
		display: flex;
		flex-direction: column;
		align-items: flex-start;
		gap: var(--space-5);
		margin-top: var(--space-12);

		h5 {
			margin: 0;
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
				padding-block: var(--space-9);
				gap: var(--space-8);
				border-bottom: none;
				position: sticky;
				top: 60px;
			}
		}

		.rightside {
			display: flex;
			flex-direction: column;
			justify-content: center;
			align-items: center;

			.main-wrapper {
				display: grid;
				grid-template-columns: 1fr 3fr;

				.timeline {
					display: flex;
					flex-direction: column;
					align-items: center;

					.line {
						flex: 1;
						border: 1px dashed rgba(56, 232, 198, 0.1);
						width: 2px;
					}

					.date-wrapper {
						background-color: var(--clr-primary-badge);
						border-radius: var(--radius-2);
						padding: var(--space-4);
						text-align: center;

						p {
							color: var(--clr-primary-main);
						}
					}
				}

				.tickets {
					overflow: hidden;
					padding: var(--space-12) var(--space-9);
				}
			}
		}
	}
</style>
