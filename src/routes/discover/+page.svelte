<script lang="ts">
	import { onMount } from 'svelte';
	import type { Event, EventWithStatus } from '$lib/types/event/event.interface.js';
	import getTrendingEventsFromBlockchain from './_actions/getTrendingEventsFromBlockchain.js';
	import EventCard from '$lib/components/events/EventCard.svelte';
	import { writable } from 'svelte/store';
	import { supabase } from '$lib/supabase/supabaseClient.js';
	import getLiveEventFromBlockchain from './_actions/getLiveEventfromBlockchain.js';
	import Float from '$lib/components/floats/Float.svelte';
	import transformEventToFloat from '$lib/utilities/transformEventToFloat.js';

	let dataFetched = false;
	let dataLoading = true;
	let trendingEvents: EventWithStatus[];

	const claimStore = writable<string[]>([], (set) => {
		const eventIds: string[] = [];

		const subscription = supabase
			.channel('claims')
			.on(
				'postgres_changes',
				{
					event: 'INSERT',
					schema: 'public',
					table: 'claims'
				},
				(payload) => {
					const event_Id = payload.new?.event_id;

					eventIds.push(event_Id);

					set(eventIds);
					fetchData();
				}
			)
			.subscribe();

		return () => supabase.removeChannel(subscription);
	});

	let liveAction = false;

	function showAlert() {
		liveAction = true;
		setTimeout(() => {
			liveAction = false;
		}, 8000);
	}

	let liveEvent: Event[] = [];

	async function fetchData() {
		try {
			if ($claimStore) {
				const lastEventId = $claimStore[$claimStore.length - 1];
				const event = await getLiveEventFromBlockchain(lastEventId);
				liveEvent.push(event);
				showAlert();
			}
		} catch (error) {
			console.error('Error fetching data:', error);
		}
	}

	onMount(async () => {
		trendingEvents = await getTrendingEventsFromBlockchain();
		dataLoading = false;
		if (trendingEvents) {
			dataFetched = true;
		}
	});
</script>

<section
	class="section"
	style={`background-image: linear-gradient(
    rgba(250, 250, 250, 0.87),
		rgba(250, 250, 250, 0.91),
    rgba(250, 250, 250, 1)
  ), url("/badges/each-event-type-floats/level-3.png")`}
>
	<div class="container-medium">
		<h2 class="w-medium">🔥Trending Events🔥</h2>

		{#if dataLoading}
			<div class="empty-state">
				<span><em>Loading trending events</em></span>
			</div>
		{:else if dataFetched}
			<div class="cards-wrapper">
				{#each trendingEvents as event}
					<div class="event-wrapper">
						<EventCard {event} display="grid" displayedInAdmin={false} hasLink={false} />
					</div>
				{/each}
			</div>
		{:else}
			<div class="empty-state">
				<span><em>No trending events</em></span>
			</div>
		{/if}
	</div>
	<div>
		<div class="printer-wrapper">
			<img src="/printer.png" alt="Printer" />
			{#if liveAction}
				<div class="cards">
					{#each liveEvent as event}
						<div class="float-wrapper">
							<Float float={transformEventToFloat(event)} maxWidth="400px" />
						</div>
					{/each}
				</div>
			{/if}
		</div>
	</div>
</section>

<style lang="scss">
	section {
		display: grid;
		grid-template-columns: 3fr 1fr;
		min-height: 85vh;

		.container-medium {
			display: flex;
			flex-direction: column;
			justify-content: flex-start;
			align-items: center;

			h2 {
				text-align: center;
				margin-bottom: var(--space-15);
			}
			.cards-wrapper {
				display: grid;
				grid-template-columns: 1fr;
				justify-content: center;
				align-items: center;
				gap: var(--space-8);
				width: 100%;

				@include mq(small) {
					grid-template-columns: 1fr 1fr;
				}

				@include mq(medium) {
					grid-template-columns: 1fr 1fr 1fr;
				}

				.event-wrapper {
					padding-bottom: var(--space-3);
				}
			}
			.empty-state {
				width: 100%;
				height: 100%;
				display: flex;
				align-items: center;
				justify-content: center;
			}
		}

		.printer-wrapper {
			display: flex;
			flex-direction: column;
			justify-content: flex-start;
			align-items: center;
			width: fit-content;
			position: relative;
			/* background-color: red; */

			img {
				width: 300px;
			}

			.cards {
				display: flex;
				flex-direction: column;
				align-items: center;
				gap: var(--space-1);
				width: 170px;
				height: auto;
				/* background-color: red; */
				position: absolute;
				top: 100%;
				transform: rotate(-100%);
				animation: appear 6s linear forwards, disappear 2s 8s forwards;

				.float-wrapper {
					transform: rotate(90deg);
				}
			}

			@keyframes appear {
				0% {
					transform: translateY(-100%);
				}
				100% {
					transform: translateY(0);
				}
			}

			@keyframes disappear {
				0%,
				100% {
					transform: translateY(0);
				}
				50% {
					transform: translateY(100%);
				}
			}
		}
	}
</style>
