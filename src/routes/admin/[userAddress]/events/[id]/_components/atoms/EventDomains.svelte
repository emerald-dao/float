<script lang="ts">
	import Icon from '@iconify/svelte';
	import type { Event } from '$lib/types/event/event.interface';
	import DomainLink from './DomainLink.svelte';

	export let event: Event;
</script>

<div class="domains-wrapper">
	<div class="row-1">
		<Icon icon="ph:link" color="var(--clr-neutral-600)" />
		<p>EVENT URLs</p>
	</div>
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

		.row-1 {
			align-items: center;
			p {
				color: var(--clr-text-off);
			}
		}
	}
</style>
