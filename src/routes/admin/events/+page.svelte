<script lang="ts">
	import { Button } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';
	import { fly } from 'svelte/transition';
	import { createSearchStore, searchHandler } from '$stores/searchBar';
	import { onDestroy, onMount } from 'svelte';
	import EventCardList from '$lib/components/events/EventCardList.svelte';
	import EventCardGrid from '$lib/components/events/EventCardGrid.svelte';

	export let data;

	let viewEventsMode: 'grid' | 'list' = 'grid';

	const setDefaultViewMode = () => {
		const screenWidth = window.innerWidth;

		if (screenWidth < 640) {
			viewEventsMode = 'grid';
		}
	};

	onMount(() => {
		window.addEventListener('resize', setDefaultViewMode);

		return () => {
			window.removeEventListener('resize', setDefaultViewMode);
		};
	});

	function handleEventsViewModeChange(buttonType: 'grid' | 'list') {
		viewEventsMode = buttonType;
	}

	$: searchEvent = data.events.map((example) => ({
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
	<div class="row-4">
		<Button color="neutral">Show inactive</Button>
		<input type="text" placeholder="Search event name or id" bind:value={$searchStore.search} />
		<div class="row-2">
			<div class={`button-wrapper ${viewEventsMode === 'grid' ? 'selected' : 'unselected'}`}>
				<Button type="transparent" on:click={() => handleEventsViewModeChange('grid')}>
					<Icon icon="basil:layout-outline" color="var(--clr-heading-inverse)" />
				</Button>
			</div>
			<div class={`button-wrapper ${viewEventsMode === 'list' ? 'selected' : 'unselected'} list`}>
				<Button type="transparent" on:click={() => handleEventsViewModeChange('list')}>
					<Icon icon="ic:round-list" color="var(--clr-heading-inverse)" />
				</Button>
			</div>
		</div>
		<Button href="/event-generator"><Icon icon="ep:circle-plus" />Create New</Button>
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
		padding: var(--space-6) 0;

		.row-4 {
			input {
				max-width: 600px;
				height: 45px;
				padding: 0;
			}

			.row-2 {
				.button-wrapper {
					display: flex;
					align-items: center;
					justify-content: center;
					border-radius: var(--radius-1);
				}

				.list {
					display: none;
					@include mq(small) {
						display: flex;
					}
				}
				.selected {
					background-color: var(--clr-primary-500);
				}

				.unselected {
					background-color: var(--clr-neutral-100);
				}
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
