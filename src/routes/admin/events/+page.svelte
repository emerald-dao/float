<script lang="ts">
	import { Button } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';
	import { fly } from 'svelte/transition';
	import { createSearchStore, searchHandler } from '$stores/searchBar';
	import { onDestroy, onMount } from 'svelte';
	import EventCardList from '$lib/components/events/EventCardList.svelte';
	import EventCardGrid from '$lib/components/events/EventCardGrid.svelte';
	import type { Event } from '$lib/types/event/event.interface.js';

	export let data;

	let viewEventsMode: 'grid' | 'list' = 'grid';
	let showInactive = true;

	const toggleInactive = () => {
		showInactive = !showInactive;
	};

	const setDefaultViewMode = () => {
		const screenWidth = window.innerWidth;

		if (screenWidth < 640) {
			viewEventsMode = 'grid';
		}
	};

	onMount(() => {
		window.addEventListener('resize', setDefaultViewMode);
		filteredEvents = data.events;

		return () => {
			window.removeEventListener('resize', setDefaultViewMode);
		};
	});

	function handleEventsViewModeChange(buttonType: 'grid' | 'list') {
		viewEventsMode = buttonType;
	}

	$: filteredEvents = showInactive
		? data.events
		: data.events.filter((event: Event) => !event.status || event.status.status === 'InProgress');

	$: searchEvent = filteredEvents.map((example) => ({
		...example,
		searchTerms: `${example.name} ${example.eventId}`
	}));

	$: searchStore = createSearchStore(searchEvent);

	$: unsubscribe = searchStore.subscribe((model) => searchHandler(model));

	onDestroy(() => {
		unsubscribe();
	});
</script>

<div class="main-wrapper" in:fly={{ x: 10, duration: 400 }}>
	<div class="commands-wrapper">
		<button class="button-wrapper" on:click={toggleInactive}>
			{showInactive ? 'Hide Inactive' : 'Show Inactive'}
		</button>
		<input type="text" placeholder="Search event name or id" bind:value={$searchStore.search} />
		<button
			class="button-wrapper grid-button"
			class:selected={viewEventsMode === 'grid'}
			on:click={() => handleEventsViewModeChange('grid')}
		>
			<Icon icon="tabler:layout-grid" />
		</button>
		<button
			class="button-wrapper list-button"
			class:selected={viewEventsMode === 'list'}
			on:click={() => handleEventsViewModeChange('list')}
		>
			<Icon icon="tabler:list" />
		</button>
		<Button href="/event-generator">
			<span class="button-text">
				<Icon icon="tabler:plus" />New Event
			</span>
		</Button>
	</div>
	<div class="events-wrapper">
		{#if $searchStore.search.length > 0 && $searchStore.filtered.length === 0}
			<p>No results found</p>
		{:else if viewEventsMode === 'grid'}
			<div class="events-grid-wrapper" in:fly={{ x: 10, duration: 400 }}>
				{#each $searchStore.filtered as event}
					<EventCardGrid {event} />
				{/each}
			</div>
		{:else}
			<div class="events-list-wrapper" in:fly={{ x: 10, duration: 400 }}>
				{#each $searchStore.filtered as event}
					<EventCardList {event} />
				{/each}
			</div>
		{/if}
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		display: flex;
		flex-direction: column;

		@include mq(medium) {
			overflow-y: auto;
		}

		.commands-wrapper {
			display: flex;
			justify-content: space-between;
			gap: var(--space-3);
			position: sticky;
			top: 0;
			background-color: var(--clr-background-primary);
			padding-block: var(--space-6);
			border-bottom: 0.5px solid var(--clr-border-primary);
			padding: var(--space-4) var(--space-14) var(--space-4) var(--space-10);

			.button-wrapper {
				border-radius: var(--radius-1);
				background-color: var(--clr-neutral-badge);
				border: 2px solid transparent;
				cursor: pointer;
				font-size: var(--font-size-1);
				display: flex;
				align-items: center;
				white-space: nowrap;
				text-align: center;
			}

			.grid-button,
			.list-button {
				display: none;

				@include mq(small) {
					display: flex;
				}
			}

			.selected {
				border: 2px solid var(--clr-heading-main);
			}

			.button-text {
				white-space: nowrap;
				text-align: center;
				display: flex;
				align-items: center;
				gap: var(--space-1);
			}
		}

		.events-grid-wrapper {
			display: flex;
			flex-direction: column;
			gap: var(--space-10);

			@include mq(medium) {
				display: grid;
				grid-template-columns: repeat(2, 1fr);
			}
		}

		.events-list-wrapper {
			display: flex;
			flex-direction: column;
			gap: var(--space-5);
		}

		.events-grid-wrapper,
		.events-list-wrapper {
			padding: var(--space-8) var(--space-14) var(--space-4) var(--space-10);
		}
	}
</style>
