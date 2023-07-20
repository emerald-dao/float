<script lang="ts">
	import Icon from '@iconify/svelte';
	import { onMount } from 'svelte';

	let selectedOption = '';

	onMount(() => {
		const currentPath = window.location.pathname;
		if (currentPath.includes('/admin/events')) {
			selectedOption = 'events';
		} else if (currentPath.includes('/admin/my-collection')) {
			selectedOption = 'collection';
		}
	});

	function selectOption(option: string) {
		selectedOption = option;
	}
</script>

<div class="column-6">
	<a
		href="/admin/events"
		class="sidebar-link {selectedOption === 'events' ? 'selected' : ''}"
		on:click={() => selectOption('events')}
	>
		<Icon icon="mdi:calendar-outline" hFlip={true} />
		Events
	</a>
	<a
		href="/admin/my-collection"
		class="sidebar-link {selectedOption === 'collection' ? 'selected' : ''}"
		on:click={() => selectOption('collection')}
	>
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

		.selected {
			color: var(--clr-neutral-50);
		}
	}
</style>
