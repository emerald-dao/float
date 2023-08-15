<script lang="ts">
	export let numberOfItems: number;
	export let noItemsMessage = 'No items found';
</script>

<div class="content-wrapper">
	{#if numberOfItems > 0}
		<slot />
	{:else}
		<div class="center empty-state-wrapper">
			<p><em>{noItemsMessage}</em></p>
		</div>
	{/if}
</div>

<style lang="scss">
	.content-wrapper {
		height: 100%;
		overflow: hidden;

		.empty-state-wrapper {
			height: 100%;
		}
	}
</style>
