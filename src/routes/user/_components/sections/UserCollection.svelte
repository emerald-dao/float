<script lang="ts">
	import Filters from '$lib/components/filters/Filters.svelte';
	import { InputWrapper } from '@emerald-dao/component-library';
	import { onDestroy, onMount } from 'svelte';
	import type { Filter } from '$lib/types/content/filters/filter.interface';
	import type { ProgressStates } from '@emerald-dao/component-library/components/ProgressStep/progress-states.type';
	import FloatTicket from '$lib/components/floats/FloatTicket.svelte';
	import Badges from '../atoms/Badges.svelte';
	import { createSearchStore, searchHandler } from '../../../../lib/stores/searchBar';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import { createFilters } from '../../_functions/filters';
	import { filterContent } from '../../_functions/filterContent';
	import { unixTimestampToFormattedDate } from '$lib/utilities/dates/unixTimestampToFormattedDate';

	export let floats: FLOAT[];

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
		filteredContent = filterContent(filters, $searchStore.filtered, activeFilters);
	} else if (filters.length > 0) {
		filteredContent = filterContent(filters, floats, activeFilters);
	} else if ($searchStore.search.length > 0) {
		filteredContent = $searchStore.filtered;
	} else {
		filteredContent = floats;
	}

	let badges: BadgesInterface[] = [];

	interface Step {
		name: string;
		state: ProgressStates;
	}

	interface BadgesInterface {
		icon: string;
		name: string;
	}

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
		<div class="filters-wrapper">
			<h5>Filters</h5>
			<Filters bind:filters />
		</div>
		<h5>Badges</h5>
		<Badges {badges} />
	</div>
	<div class="rightside">
		{#await filteredContent then contents}
			{#if contents.length > 0}
				{#each contents as float}
					<div class="main-wrapper">
						<div class="timeline">
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
						<div class="tickets">
							<FloatTicket {float} />
						</div>
					</div>
				{/each}
			{:else}
				<span><em>No content found</em></span>
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
				gap: var(--space-8);
				border-bottom: none;
				position: sticky;
				top: 90px;
			}

			.filters-wrapper {
				display: none;

				@include mq(small) {
					display: flex;
					flex-direction: column;
					gap: var(--space-4);
				}

				@include mq(medium) {
					gap: var(--space-8);
				}
			}
		}

		.rightside {
			display: flex;
			flex-direction: column;
			justify-content: center;
			align-items: center;

			.main-wrapper {
				display: flex;
				flex-direction: column;
				justify-content: center;

				@include mq(small) {
					display: grid;
					grid-template-columns: 1fr 3fr;
				}

				.timeline {
					display: flex;
					flex-direction: column;
					align-items: center;

					.line {
						@include mq(small) {
							flex: 1;
							border: 1px dashed rgba(56, 232, 198, 0.1);
							width: 2px;
						}
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
					padding: var(--space-6) var(--space-4);

					@include mq(small) {
						padding: var(--space-12) var(--space-9);
					}
				}
			}
		}
	}
</style>
