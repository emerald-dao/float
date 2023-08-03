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
	<input type="text" placeholder="Search event..." bind:value={$searchStore.search} />
	<HideShowInactive bind:showInactive />
	<GridAndListToggle bind:viewMode />
	<div class="button-wrapper">
		<Button href="/event-generator" size="small">
			<span class="button-text">
				<Icon icon="tabler:plus" />New Event
			</span>
		</Button>
	</div>
</nav>

<style lang="scss">
	nav {
		display: flex;
		justify-content: space-between;
		align-items: stretch;
		gap: var(--space-3);
		background-color: var(--clr-background-primary);
		border-bottom: 0.5px solid var(--clr-border-primary);
		padding: var(--space-3) var(--space-6);
		box-shadow: 0px 0px 10px 0px var(--clr-shadow-primary);
		z-index: 2;

		@include mq(medium) {
			padding: var(--space-4) var(--space-14) var(--space-4) var(--space-10);
		}

		.button-wrapper {
			height: 100%;
			display: none;

			@include mq(medium) {
				display: flex;
			}

			.button-text {
				white-space: nowrap;
				text-align: center;
				display: flex;
				align-items: center;
				justify-content: center;
				gap: var(--space-1);
			}
		}
	}
</style>
