<script lang="ts">
	import Icon from '@iconify/svelte';

	export let numberOfItems: number;
	export let noItemsMessage = 'No items found';
</script>

<div class="content-wrapper">
	{#if numberOfItems > 0}
		<slot />
	{:else}
		<div class="center empty-state-wrapper">
			<p>
				<em>
					<Icon icon="tabler:mood-annoyed" inline={true} />
					{noItemsMessage}
				</em>
			</p>
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

	em {
		color: var(--clr-text-off);
		font-size: var(--font-size-1);
	}
</style>
