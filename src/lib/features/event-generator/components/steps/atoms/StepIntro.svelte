<script lang="ts">
	import CanBeEditedLater from './CanBeEditedLater.svelte';

	export let title: string | undefined;
	export let description: string | undefined;
	export let canBeEditedLater: boolean | null = null;
	export let alignCenter = false;
</script>

{#if description || title}
	<div class="column-3" class:align-center={alignCenter}>
		{#if title}
			<h2 class="h5 w-medium" class:align-center={alignCenter}>{title}</h2>
		{/if}
		<CanBeEditedLater {canBeEditedLater} />
		{#if description}
			<p class:align-center={alignCenter}>{description}</p>
		{/if}
	</div>
{/if}

<style lang="scss">
	.align-center {
		align-items: center;
		text-align: center;
	}
</style>
