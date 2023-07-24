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
	<div class="row-2">
		<div class="button-wrapper">
			<Button color="neutral" type="transparent" on:click={toggleInactive}>
				{showInactive ? 'Hide Inactive' : 'Show Inactive'}
			</Button>
		</div>
		<input type="text" placeholder="Search event name or id" bind:value={$searchStore.search} />

		<div class={`button-wrapper ${viewEventsMode === 'grid' ? 'selected' : ''}`}>
			<Button type="transparent" on:click={() => handleEventsViewModeChange('grid')}>
				<Icon icon="tabler:layout-grid" color="var(--clr-heading-main)" />
			</Button>
		</div>
		<div class={`button-wrapper ${viewEventsMode === 'list' ? 'selected' : ''} list`}>
			<Button type="transparent" on:click={() => handleEventsViewModeChange('list')}>
				<Icon icon="tabler:list" color="var(--clr-heading-main)" />
			</Button>
		</div>

		<Button href="/event-generator"><Icon icon="tabler:circle-plus" />Create New</Button>
	</div>
	{#if viewEventsMode === 'grid'}
		<div class="events-wrapper" in:fly={{ x: 10, duration: 400 }}>
			{#each $searchStore.filtered as event}
				<EventCardGrid {event} />
			{/each}
		</div>
	{:else}
		<div class="list" in:fly={{ x: 10, duration: 400 }}>
			{#each $searchStore.filtered as event}
				<EventCardList {event} />
			{/each}
		</div>
	{/if}
</div>

<style lang="scss">
	.main-wrapper {
		display: flex;
		flex-direction: column;
		justify-content: center;
		gap: var(--space-10);
		padding: var(--space-6) var(--space-18) var(--space-6) var(--space-6);

		.row-2 {
			display: grid;
			grid-template-columns: 0.2fr 1.4fr 0.05fr 0.2fr;
			@include mq(small) {
				grid-template-columns: 0.3fr 1.4fr 0.07fr 0.07fr auto;
			}
			.button-wrapper {
				display: flex;
				align-items: center;
				justify-content: center;
				border-radius: var(--radius-1);
				background-color: rgba(133, 133, 133, 0.1);
			}

			.list {
				display: none;
				@include mq(small) {
					display: flex;
				}
			}
			.selected {
				border: 2px solid var(--clr-heading-main);
			}
		}

		.events-wrapper {
			display: flex;
			flex-direction: column;
			gap: var(--space-10);

			@include mq(medium) {
				display: grid;
				grid-template-columns: repeat(2, 1fr);
			}
		}

		.list {
			display: flex;
			flex-direction: column;
			gap: var(--space-5);
		}
	}
</style>
