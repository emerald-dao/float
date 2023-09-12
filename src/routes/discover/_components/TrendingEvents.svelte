<script lang="ts">
	import EventCard from '$lib/components/events/EventCard.svelte';
	import type { EventWithStatus } from '$lib/types/event/event.interface';

	export let events: EventWithStatus[];
</script>

<div class="main-wrapper">
	<h4 class="w-medium">🔥 Trending Events 🔥</h4>
	<div class="cards-wrapper">
		{#each events as event}
			<div class="event-wrapper">
				<EventCard {event} display="grid" displayedInAdmin={false} hasLink={false} />
			</div>
		{/each}
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		display: flex;
		flex-direction: column;
		justify-content: center;
		align-items: center;
		gap: var(--space-10);

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
	}
</style>
