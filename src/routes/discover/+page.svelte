<script lang="ts">
	import { onMount } from 'svelte';
	import type { EventWithStatus } from '$lib/types/event/event.interface.js';
	import getTrendingEventsFromBlockchain from './_actions/getTrendingEventsFromBlockchain.js';
	import EventCard from '$lib/components/events/EventCard.svelte';

	let dataFetched = false;
	let dataLoading = true;
	let trendingEvents: EventWithStatus[];

	onMount(async () => {
		trendingEvents = await getTrendingEventsFromBlockchain();
		dataLoading = false;
		if (trendingEvents) {
			dataFetched = true;
		}
	});
</script>

<section
	class="section-large"
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
</section>

<style lang="scss">
	section {
		min-height: 85vh;

		.container-medium {
			display: flex;
			flex-direction: column;
			justify-content: center;
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
	}
</style>
