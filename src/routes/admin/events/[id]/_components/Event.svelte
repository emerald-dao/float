<script type="ts">
	import { fly } from 'svelte/transition';
	import type { Event } from '$lib/types/event/event.interface';
	import Domain from './atoms/Domain.svelte';
	import Actions from './atoms/Actions.svelte';
	import EventInfo from './EventInfo.svelte';
	import { EVENT_TYPES } from '$lib/types/event/even-type.type';

	let event: Event = {
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
		eventType: EVENT_TYPES[0]
	};

	let claimableLinks = [
		{ type: 'Page', link: 'https://floats.city/event/4359' },
		{ type: 'Qr', link: 'https://floats.city/qr/4359' }
	];
</script>

<div class="main-wrapper" in:fly={{ x: 10, duration: 400 }}>
	<div class="left-wrapper">
		<div class="header-wrapper">
			<div class="row-3">
				<img src={event.image} alt="logo" height="57" width="68" />
				<h4>{event.name}</h4>
			</div>
			<span class="small">{event.eventType}</span>
		</div>
		<Domain {claimableLinks} />
		<Actions />
	</div>
	<div class="right-wrapper">
		<EventInfo />
	</div>
</div>

<style type="scss">
	.main-wrapper {
		display: grid;
		grid-template-columns: 2fr 3fr;
		justify-content: center;
		gap: var(--space-6);

		.left-wrapper {
			display: flex;
			flex-direction: column;
			gap: var(--space-10);
			padding: var(--space-6) 0;

			.header-wrapper {
				display: flex;
				flex-direction: column;
				gap: var(--space-2);

				.row-3 {
					align-items: center;
				}

				span {
					text-align: center;
					width: fit-content;
					border: var(--border-width-primary) solid var(--clr-border-primary);
					padding: var(--space-1) var(--space-2);
					border-radius: var(--radius-2);
				}
			}
		}

		.right-wrapper {
			background-color: var(--clr-background-secondary);
		}
	}
</style>
