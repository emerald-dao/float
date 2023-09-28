<script lang="ts">
	import EventCard from '$lib/components/events/EventCard.svelte';
	import { writable } from 'svelte/store';
	import { supabase } from '$lib/supabase/supabaseClient.js';
	import getLiveEventFromBlockchain from './_actions/getLiveEventfromBlockchain.js';
	import Float from '$lib/components/floats/Float.svelte';
	import transformEventToFloat from '$lib/utilities/transformEventToFloat.js';
	import { fly, slide } from 'svelte/transition';
	import { onMount } from 'svelte';
	import type { Event } from '$lib/types/event/event.interface.js';
	import { network } from '$flow/config.js';

	export let data;

	const claimStore = writable<{ eventIds: string[]; userAddresses: string[] }>(
		{ eventIds: [], userAddresses: [] },
		(set) => {
			const eventIds: string[] = [];
			const userAddresses: string[] = [];

			const subscription = supabase
				.channel('claims')
				.on(
					'postgres_changes',
					{
						event: 'INSERT',
						schema: 'public',
						table: 'claims',
						filter: `network=eq.${network}`
					},
					(payload) => {
						const event_id = payload.new?.event_id;
						const user_address = payload.new?.user_address;

						eventIds.push(event_id);
						userAddresses.push(user_address);

						set({ eventIds, userAddresses });
						fetchNewEventData();
					}
				)
				.subscribe();

			return () => supabase.removeChannel(subscription);
		}
	);

	let latestClaims: {
		event: Event;
		user_address: any;
	}[];

	onMount(() => {
		latestClaims = data.latestFloatsClaimed;
	});

	async function fetchNewEventData() {
		try {
			if ($claimStore) {
				const lastEventId = $claimStore.eventIds[$claimStore.eventIds.length - 1];
				const lastUserAddress = $claimStore.userAddresses[$claimStore.userAddresses.length - 1];
				const event = await getLiveEventFromBlockchain(lastEventId);
				latestClaims = [{ event, user_address: lastUserAddress }, ...latestClaims];
			}
		} catch (error) {
			console.error('Error fetching data:', error);
		}
	}
</script>

<section
	class="section-large"
	style={`background-image: linear-gradient(
    rgba(250, 250, 250, 0.92),
		rgba(250, 250, 250, 0.94),
    rgba(250, 250, 250, 1)
  ), url("/badges/each-event-type-floats/level-3.png") `}
>
	<div class="container-medium">
		<h2 class="w-medium h3">🔥Trending Events🔥</h2>
		{#if data.trendingEvents.length > 0}
			<div class="cards-wrapper">
				{#each data.trendingEvents as event}
					<EventCard {event} display="grid" displayedInAdmin={false} hasLink={false} />
				{/each}
			</div>
		{:else}
			<div class="empty-state">
				<span><em>No trending events</em></span>
			</div>
		{/if}
	</div>
</section>
<section class="live-tickets-wrapper">
	<h3 class="w-medium align-center h5">Latest claims</h3>
	{#if latestClaims && latestClaims.length > 0}
		<div class="cards">
			{#each latestClaims as eventClaimed, i (eventClaimed.event)}
				<div in:slide={{ axis: 'x', duration: 4000 }}>
					<div in:fly={{ x: -400, duration: 4000, opacity: 1 }}>
						<Float
							float={transformEventToFloat(eventClaimed.event, eventClaimed.user_address)}
							minWidth="400px"
							hasShadow={false}
						/>
					</div>
				</div>
			{/each}
		</div>
	{:else}
		<div class="empty-state">
			<span><em>No claims reported lately</em></span>
		</div>
	{/if}
</section>

<style lang="scss">
	section {
		position: relative;

		.container-medium {
			display: flex;
			flex-direction: column;
			gap: var(--space-12);
			align-items: center;

			h2 {
				text-align: center;
			}

			.cards-wrapper {
				display: grid;
				grid-template-columns: 1fr;
				gap: var(--space-10);

				@include mq(small) {
					grid-template-columns: 1fr 1fr;
				}

				@include mq(medium) {
					grid-template-columns: 1fr 1fr 1fr;
				}
			}
		}

		.empty-state {
			width: 100%;
			height: 100%;
			display: flex;
			align-items: center;
			justify-content: center;
			margin-top: var(--space-8);
		}
	}

	.live-tickets-wrapper {
		display: none;

		@include mq(small) {
			display: flex;
			flex-direction: column;
			align-items: center;
			gap: var(--space-8);
			background-color: var(--clr-neutral-badge);
			border-top: 0.5px solid var(--clr-border-primary);
			box-shadow: inset 0px 0px 15px rgba(0, 0, 0, 0.05);
		}

		h3 {
			text-align: center;
		}

		.cards {
			display: flex;
			justify-content: flex-start;
			width: 100%;
			overflow: visible;
			transform: transformX(-100%);
			animation: appear 4s linear forwards;
		}

		@keyframes appear {
			0% {
				transform: translateX(-100%);
			}
			100% {
				transform: translateX(0%);
			}
		}
	}
</style>
