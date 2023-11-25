<script lang="ts">
	import type { EventWithStatus } from '$lib/types/event/event.interface';
	import EventCardContent from './EventCardContent.svelte';

	export let event: EventWithStatus;
	export let display: 'grid' | 'list' = 'list';
	export let displayedInAdmin = true;
	export let hasLink = true;

	let link: string;
	if (displayedInAdmin) {
		link = `/admin/events/${event.eventId}`;
	} else {
		link = `/event/${event.host}/${event.eventId}`;
	}
</script>

{#if hasLink}
	<a class="main-wrapper" href={link}>
		<EventCardContent bind:displayedInAdmin bind:display bind:event />
	</a>
{:else}
	<div class="main-wrapper">
		<EventCardContent bind:displayedInAdmin bind:display bind:event />
	</div>
{/if}

<style lang="scss">
	.main-wrapper {
		text-decoration: none;
		color: unset;
		width: 100%;
		display: flex;
	}
</style>
