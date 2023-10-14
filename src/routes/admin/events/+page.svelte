<script lang="ts">
	import { fly } from 'svelte/transition';
	import { createSearchStore, searchHandler } from '$stores/searchBar';
	import { getContext, onDestroy, onMount } from 'svelte';
	import EventCard from '$lib/components/events/EventCard.svelte';
	import EventsTopNavbar from './_components/EventsTopNavbar.svelte';
	import type { EventWithStatus } from '$lib/types/event/event.interface';
	import type { Writable } from 'svelte/store';

	let eventsWithStatus: Writable<EventWithStatus[]> = getContext('events');

	let viewMode: 'grid' | 'list' = 'grid';
	let showInactive = true;

	const setDefaultViewMode = () => {
		const screenWidth = window.innerWidth;

		if (screenWidth < 640) {
			viewMode = 'grid';
		}
	};

	onMount(() => {
		window.addEventListener('resize', setDefaultViewMode);

		return () => {
			window.removeEventListener('resize', setDefaultViewMode);
		};
	});

	$: filteredEvents = showInactive
		? $eventsWithStatus
		: $eventsWithStatus.filter((event) => event.status.generalStatus === 'available');

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
		{#if $searchStore.filtered.length === 0 || $eventsWithStatus.length === 0}
			<em>No events found</em>
		{:else if viewMode === 'grid'}
			<div class="events-grid-wrapper" in:fly={{ x: 10, duration: 400 }}>
				{#each $searchStore.filtered as event (event.eventId)}
					<EventCard {event} display="grid" />
				{/each}
			</div>
		{:else}
			<div class="events-list-wrapper" in:fly={{ x: 10, duration: 400 }}>
				{#each $searchStore.filtered as event (event.eventId)}
					<EventCard {event} display="list" />
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
				padding: var(--space-8) var(--space-14) var(--space-8) var(--space-10);
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
