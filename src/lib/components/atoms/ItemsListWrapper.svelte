<script lang="ts">
	export let numberOfItems: number;
	export let noItemsMessage = 'No items found';
</script>

<div>
	{#if numberOfItems > 0}
		<slot />
	{:else}
		<div class="center">
			<p><em>{noItemsMessage}</em></p>
		</div>
	{/if}
</div>
