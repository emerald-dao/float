<script lang="ts">
	import type { Event } from '$lib/types/event/event.interface';
	import DomainLink from '../[id]/_components/atoms/DomainLink.svelte';
	import EventDataTitle from '../_components/EventDataTitle.svelte';

	export let event: Event;
</script>

<div class="domains-wrapper">
	<EventDataTitle icon="tabler:link">Event URLs</EventDataTitle>
	<DomainLink id={event.eventId} linkType="eventPage" />
	<DomainLink id={event.eventId} linkType="qr" />
</div>

<style lang="scss">
	.domains-wrapper {
		display: flex;
		flex-direction: column;
		gap: var(--space-3);
		padding-inline: var(--space-6);

		@include mq(medium) {
			padding-inline: var(--space-8);
		}
	}
</style>
