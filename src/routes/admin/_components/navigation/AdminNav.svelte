<script lang="ts">
	import Icon from '@iconify/svelte';
</script>

<div class="column-6">
	<a href="/admin/events" class="sidebar-link">
		<Icon icon="mdi:calendar-outline" hFlip={true} />
		Events
	</a>
	<a href="/admin/my-collection" class="sidebar-link">
		<Icon icon="tabler:ticket" />
		My collection
	</a>
</div>

<style lang="scss">
	.column-6 {
		padding: var(--space-6) 0;

		.sidebar-link {
			font-size: var(--font-size-3);
			display: flex;
		}
	}
</style>
