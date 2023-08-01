<script lang="ts">
	import { Button } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';
	import GridAndListToggle from './GridAndListToggle.svelte';
	import HideShowInactive from './HideShowInactive.svelte';
	import type { createSearchStore } from '$stores/searchBar';

	export let viewMode: 'grid' | 'list';
	export let showInactive: boolean;
	export let searchStore: ReturnType<typeof createSearchStore>;
</script>

<nav>
	<input type="text" placeholder="Search event name or id..." bind:value={$searchStore.search} />
	<GridAndListToggle bind:viewMode />
	<HideShowInactive bind:showInactive />
	<Button href="/event-generator" size="small">
		<span class="button-text">
			<Icon icon="tabler:plus" />New Event
		</span>
	</Button>
</nav>

<style lang="scss">
	nav {
		display: flex;
		justify-content: space-between;
		gap: var(--space-3);
		background-color: var(--clr-background-primary);
		padding-block: var(--space-6);
		border-bottom: 0.5px solid var(--clr-border-primary);
		padding: var(--space-4) var(--space-14) var(--space-4) var(--space-10);

		.button-text {
			white-space: nowrap;
			text-align: center;
			display: flex;
			align-items: center;
			justify-content: center;
			gap: var(--space-1);
		}
	}
</style>
