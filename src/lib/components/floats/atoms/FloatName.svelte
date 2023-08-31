<script lang="ts">
	import { EVENT_TYPE_DETAILS } from '$lib/types/event/event-type.type';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import Icon from '@iconify/svelte';

	export let float: FLOAT;
</script>

<div class="column-space-between heading-wrapper">
	{#if float.eventName.length > 0}
		<h3 class="w-medium">{float.eventName}</h3>
	{:else}
		<h3 class="w-medium event-name-placeholder">Event Name</h3>
	{/if}
</div>

<style lang="scss">
	.heading-wrapper {
		overflow: hidden;

		h3 {
			font-size: 1.47em;
			text-overflow: ellipsis;
			white-space: nowrap;
			overflow: hidden;
			width: 100%;
			color: var(--clr-heading-main);
			line-height: 1.2em;
			margin-bottom: 0.25em;

			&.event-name-placeholder {
				color: var(--clr-text-off);
			}
		}
	}
</style>
