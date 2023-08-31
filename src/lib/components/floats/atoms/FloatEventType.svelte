<script lang="ts">
	import { EVENT_TYPE_DETAILS, type EventType } from '$lib/types/event/event-type.type';
	import Icon from '@iconify/svelte';

	export let eventType: EventType;
</script>

<div class="main-wrapper">
	<Icon icon="tabler:code" width="1.1em" color="var(--clr-text-off)" />
	<span class="event-type">{EVENT_TYPE_DETAILS[eventType].eventTypeName}</span>
</div>

<style lang="scss">
	.main-wrapper {
		display: flex;
		flex-direction: row;
		align-items: center;
		gap: 0.2em;
	}

	.event-type {
		font-size: 1em;
		color: var(--clr-text-off);
	}
</style>
