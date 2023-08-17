<script lang="ts">
	import TagToggle from '$lib/components/atoms/TagToggle.svelte';
	import type { GroupWithFloatsIds } from '$lib/features/groups/types/group.interface';

	export let groups: GroupWithFloatsIds[];
	export let selectedGroupsIds: number[] = [];
</script>

{#if groups}
	<div class="tags-wrapper">
		{#each groups as group}
			<TagToggle
				icon=""
				name={group.name}
				on:selected={() => (selectedGroupsIds = [...selectedGroupsIds, group.id])}
				on:unselected={() =>
					(selectedGroupsIds = selectedGroupsIds.filter((id) => id !== group.id))}
			>
				{group.name}
			</TagToggle>
		{/each}
	</div>
{/if}

<style lang="scss">
	.tags-wrapper {
		display: flex;
		flex-direction: row;
		gap: var(--space-2);
		flex-wrap: wrap;
	}
</style>
