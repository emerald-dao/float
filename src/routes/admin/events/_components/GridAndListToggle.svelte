<script lang="ts">
	import Icon from '@iconify/svelte';

	export let viewMode: 'grid' | 'list';

	function handleViewModeChange(buttonType: 'grid' | 'list') {
		viewMode = buttonType;
	}
</script>

<div class="row">
	<button
		class="grid-button"
		class:selected={viewMode === 'grid'}
		on:click={() => handleViewModeChange('grid')}
	>
		<Icon icon="tabler:layout-grid" />
	</button>
	<button
		class="list-button"
		class:selected={viewMode === 'list'}
		on:click={() => handleViewModeChange('list')}
	>
		<Icon icon="tabler:list" />
	</button>
</div>

<style lang="scss">
	div {
		border: 1px solid var(--clr-border-primary);
		border-radius: var(--radius-1);
		background-color: var(--clr-neutral-badge);

		button {
			display: none;
			min-width: var(--space-10);
			cursor: pointer;
			border: none;
			background-color: transparent;
			color: var(--clr-text-off);
			transition: all 0.3s ease-in-out;
			border-radius: var(--radius-0);

			@include mq(small) {
				display: flex;
				align-items: center;
				justify-content: center;
			}

			&.grid-button {
				margin: var(--space-1) 0 var(--space-1) var(--space-1);
			}

			&.list-button {
				margin: var(--space-1) var(--space-1) var(--space-1) 0;
			}
		}
	}

	button.selected {
		color: var(--clr-heading-main);
		background-color: var(--clr-surface-primary);
		box-shadow: 0px 2px 6px 0 var(--clr-shadow-primary);
	}
</style>
