<script lang="ts">
	import type { FLOAT } from '$lib/types/float/float.interface';

	export let float: FLOAT;
	export let fontSize = '1.47em';
</script>

<div class="column-space-between heading-wrapper">
	{#if float.eventName.length > 0}
		<h3 style={`font-size: ${fontSize}`} class="w-medium">{float.eventName}</h3>
	{:else}
		<h3 style={`font-size: ${fontSize}`} class="w-medium event-name-placeholder">Event Name</h3>
	{/if}
</div>

<style lang="scss">
	.heading-wrapper {
		overflow: hidden;

		h3 {
			text-overflow: ellipsis;
			white-space: nowrap;
			overflow: hidden;
			width: 100%;
			color: var(--clr-heading-main);
			line-height: 1.2em;

			&.event-name-placeholder {
				color: var(--clr-text-off);
			}
		}
	}
</style>
