<script lang="ts">
	import { fly } from 'svelte/transition';
	import { createSearchStore, searchHandler } from '$stores/searchBar';
	import { onDestroy, onMount } from 'svelte';
	import EventCardList from '$lib/components/events/EventCardList.svelte';
	import EventCardGrid from '$lib/components/events/EventCardGrid.svelte';
	import type { Event } from '$lib/types/event/event.interface.js';
	import EventsTopNavbar from './_components/EventsTopNavbar.svelte';

	export let data;

	let viewMode: 'grid' | 'list' = 'grid';
	let showInactive = false;

	const setDefaultViewMode = () => {
		const screenWidth = window.innerWidth;

		if (screenWidth < 640) {
			viewMode = 'grid';
		}
	};

	onMount(() => {
		window.addEventListener('resize', setDefaultViewMode);
		filteredEvents = data.events;

		return () => {
			window.removeEventListener('resize', setDefaultViewMode);
		};
	});

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
	<EventsTopNavbar bind:viewMode bind:showInactive bind:searchStore />
	<div class="events-wrapper">
		{#if $searchStore.search.length > 0 && $searchStore.filtered.length === 0}
			<p>No results found</p>
		{:else if viewMode === 'grid'}
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
		overflow: hidden;

		.events-wrapper {
			padding: var(--space-6);

			@include mq(medium) {
				padding: var(--space-8) var(--space-14) var(--space-4) var(--space-10);
				overflow-y: auto;
			}
		}

		.events-grid-wrapper {
			display: flex;
			flex-direction: column;
			gap: var(--space-6);

			@include mq(medium) {
				gap: var(--space-10);
				display: grid;
				grid-template-columns: repeat(2, 1fr);
			}
		}

		.events-list-wrapper {
			display: flex;
			flex-direction: column;
			gap: var(--space-5);
		}
	}
</style>
