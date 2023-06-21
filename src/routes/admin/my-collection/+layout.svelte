<script type="ts">
	import { fly } from 'svelte/transition';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import { Button } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';
	import FloatSmallTicket from '$lib/components/floats/FloatSmallTicket.svelte';
	import { createSearchStore, searchHandler } from '$stores/searchBar';
	import { onDestroy } from 'svelte';

	const floats: FLOAT[] = [
		{
			id: '1234',
			dateReceived: '6/14/2023',
			eventDescription: 'Event description 1',
			originalRecipient: 'John Doe',
			eventName: 'Emerald City',
			eventType: 'hackathon',
			eventHost: 'Emerald DAO',

			eventId: '12',
			eventImage:
				'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',
			eventLogo:
				'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',

			serial: 'NO IDEA',
			totalSupply: null,
			transferrable: false
		},
		{
			id: '1234',
			dateReceived: '5/14/2023',
			eventDescription: 'Event description 2',
			originalRecipient: 'John Doe',
			eventName: 'Emerald City',
			eventType: 'workshop',
			eventHost: 'Emerald DAO',

			eventId: '34',
			eventImage:
				'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',
			eventLogo:
				'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',

			serial: 'NO IDEA',
			totalSupply: null,
			transferrable: false
		},
		{
			id: '1234',
			dateReceived: '4/14/2023',
			eventDescription: 'Event description 3',
			originalRecipient: 'John Doe',
			eventName: 'Emerald City',
			eventType: 'conference',
			eventHost: 'Emerald DAO',

			eventId: '56',
			eventImage:
				'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',
			eventLogo:
				'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',

			serial: 'NO IDEA',
			totalSupply: null,
			transferrable: false
		},
		{
			id: '1234',
			dateReceived: '4/5/2023',
			eventDescription: 'Event description 4',
			originalRecipient: 'John Doe',
			eventName: 'Emerald City',
			eventType: 'other',
			eventHost: 'Emerald DAO',

			eventId: '78',
			eventImage:
				'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',
			eventLogo:
				'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',

			serial: 'NO IDEA',
			totalSupply: null,
			transferrable: false
		},
		{
			id: '1234',
			dateReceived: '4/5/2023',
			eventDescription: 'Event description 4',
			originalRecipient: 'John Doe',
			eventName: 'Emerald City',
			eventType: 'other',
			eventHost: 'Emerald DAO',

			eventId: '910',
			eventImage:
				'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',
			eventLogo:
				'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',

			serial: 'NO IDEA',
			totalSupply: null,
			transferrable: false
		},
		{
			id: '1234',
			dateReceived: '4/5/2023',
			eventDescription: 'Event description 4',
			originalRecipient: 'John Doe',
			eventName: 'Emerald City',
			eventType: 'other',
			eventHost: 'Emerald DAO',

			eventId: '1112',
			eventImage:
				'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',
			eventLogo:
				'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',

			serial: 'NO IDEA',
			totalSupply: null,
			transferrable: false
		},
		{
			id: '1234',
			dateReceived: '4/5/2023',
			eventDescription: 'Event description 4',
			originalRecipient: 'John Doe',
			eventName: 'Emerald City',
			eventType: 'other',
			eventHost: 'Emerald DAO',

			eventId: '1314',
			eventImage:
				'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',
			eventLogo:
				'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',

			serial: 'NO IDEA',
			totalSupply: null,
			transferrable: false
		},
		{
			id: '1234',
			dateReceived: '4/5/2023',
			eventDescription: 'Event description 4',
			originalRecipient: 'John Doe',
			eventName: 'Emerald City',
			eventType: 'other',
			eventHost: 'Emerald DAO',

			eventId: '1516',
			eventImage:
				'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',
			eventLogo:
				'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',

			serial: 'NO IDEA',
			totalSupply: null,
			transferrable: false
		},
		{
			id: '1234',
			dateReceived: '4/5/2023',
			eventDescription: 'Event description 4',
			originalRecipient: 'John Doe',
			eventName: 'Emerald City',
			eventType: 'other',
			eventHost: 'Emerald DAO',

			eventId: '1718',
			eventImage:
				'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',
			eventLogo:
				'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',

			serial: 'NO IDEA',
			totalSupply: null,
			transferrable: false
		}
	];

	$: searchEvent = floats.map((example) => ({
		...example,

		searchTerms: `${example.eventName} ${example.eventId}`
	}));

	$: searchStore = createSearchStore(searchEvent);

	$: unsubscribe = searchStore.subscribe((model) => searchHandler(model));

	onDestroy(() => {
		unsubscribe();
	});
</script>

<div class="main-wrapper" in:fly={{ x: 10, duration: 400 }}>
	<div class="left-wrapper">
		<div class="top-wrapper">
			<div class="title-wrapper">
				<h5>My Collection</h5>
				<p class="medium">41 FLOATs</p>
			</div>
			<div class="input-wrapper">
				<input type="text" placeholder="Search event name or id" bind:value={$searchStore.search} />
				<div class="button-wrapper">
					<Button type="transparent">
						<Icon icon="tabler:arrows-sort" color="var(--clr-text-main)" />
					</Button>
				</div>
			</div>
		</div>
		<div class="bottom-wrapper">
			{#if $searchStore.search.length > 0 && $searchStore.filtered.length === 0}
				<p>No results found</p>
			{:else}
				{#each $searchStore.filtered as float}
					<FloatSmallTicket {float} />
				{/each}
			{/if}
		</div>
	</div>
	<div class="right-wrapper">
		<slot />
	</div>
</div>

<style type="scss">
	.main-wrapper {
		display: grid;
		grid-template-columns: 2fr 3fr;
		justify-content: center;
		gap: var(--space-4);

		.left-wrapper {
			display: flex;
			flex-direction: column;
			gap: var(--space-9);
			padding: var(--space-6) var(--space-2);

			.top-wrapper {
				display: flex;
				flex-direction: column;
				gap: var(--space-4);
				justify-content: center;
				padding-bottom: var(--space-3);
				border-bottom: var(--border-width-primary) solid var(--clr-border-primary);

				.title-wrapper {
					display: flex;
					justify-content: space-between;
					align-items: center;

					h5 {
						margin: 0;
					}
				}

				.input-wrapper {
					display: grid;
					grid-template-columns: 3fr 1fr;
					justify-content: space-between;

					.button-wrapper {
						display: flex;
						justify-content: flex-end;
					}
				}
			}

			.bottom-wrapper {
				display: flex;
				flex-direction: column;
				gap: var(--space-5);
			}
		}

		.right-wrapper {
			background-color: var(--clr-background-secondary);
		}
	}
</style>
