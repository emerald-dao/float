<script type="ts">
	import { Button } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';
	import { fly } from 'svelte/transition';
	import type { Event } from '$lib/types/event/event.interface';
	import { EventTypeEnum } from '$lib/types/content/metadata/event-types.enum';
	import { createSearchStore, searchHandler } from '$stores/searchBar';
	import { onDestroy } from 'svelte';
	import EventCardList from '$lib/components/events/EventCardList.svelte';
	import EventCardGrid from '$lib/components/events/EventCardGrid.svelte';

	let viewEventsMode: 'grid' | 'list' = 'grid';

	// Function to handle button click
	function handleButtonClick(buttonType: 'grid' | 'list') {
		viewEventsMode = buttonType;
	}

	const events: Event[] = [
		{
			claimable: true,
			dateCreated: '06/05/2023',
			description: 'This is the first mock',
			eventId: '56',
			extraMetadata: { key: 'string' },
			groups: ['TRY'],
			host: 'Twitter',
			image:
				'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',
			name: 'FIRST EVENT',
			totalSupply: '2,306',
			transferrable: false,
			url: 'https://www.google.com.uy/',
			verifiers: [],

			// Added by Chino
			eventType: EventTypeEnum.Conference
		},
		{
			claimable: true,
			dateCreated: '06/05/2023',
			description: 'This is the second mock',
			eventId: '34',
			extraMetadata: { key: 'string' },
			groups: ['TRY'],
			host: 'Twitter',
			image:
				'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',
			name: 'SECOND EVENT',
			totalSupply: '2,306',
			transferrable: false,
			url: 'https://www.google.com.uy/',
			verifiers: [{ dateStart: '06/05/2023', dateEnding: '06/20/2023' }],

			// Added by Chino
			eventType: EventTypeEnum.Workshop
		},
		{
			claimable: true,
			dateCreated: '06/05/2023',
			description: 'This is the third mock',
			eventId: '12',
			extraMetadata: { key: 'string' },
			groups: ['TRY'],
			host: 'Twitter',
			image:
				'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',
			name: 'THIRD EVENT',
			totalSupply: '2,306',
			transferrable: false,
			url: 'https://www.google.com.uy/',
			verifiers: [{ dateStart: '06/05/2023', dateEnding: '06/20/2023' }],

			// Added by Chino
			eventType: EventTypeEnum.Online
		}
	];

	$: searchEvent = events.map((example) => ({
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
				<Button type="transparent" on:click={() => handleButtonClick('grid')}>
					<Icon icon="basil:layout-outline" color="var(--clr-heading-inverse)" />
				</Button>
			</div>
			<div class={`button-wrapper ${viewEventsMode === 'list' ? 'selected' : 'unselected'}`}>
				<Button type="transparent" on:click={() => handleButtonClick('list')}>
					<Icon icon="ic:round-list" color="var(--clr-heading-inverse)" />
				</Button>
			</div>
		</div>
		<Button href="/event-generator"><Icon icon="ep:circle-plus" />Create New</Button>
	</div>
	{#if selectedButton === 'layout'}
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

<style type="scss">
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

				.selected {
					background-color: var(--clr-primary-500);
				}

				.unselected {
					background-color: var(--clr-neutral-100);
				}
			}
		}

		.events-wrapper {
			width: 100%;
			display: grid;
			grid-template-columns: repeat(2, 1fr);
			gap: var(--space-10);
		}

		.list {
			display: flex;
			flex-direction: column;
			gap: var(--space-5);
		}
	}
</style>
