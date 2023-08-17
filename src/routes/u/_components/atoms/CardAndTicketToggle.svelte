<script lang="ts">
	import Icon from '@iconify/svelte';

	export let viewMode: 'cards' | 'tickets';

	function handleViewModeChange(buttonType: 'cards' | 'tickets') {
		viewMode = buttonType;
	}
</script>

<div class="main-wrapper row">
	<button
		class="grid-button"
		class:selected={viewMode === 'cards'}
		on:click={() => handleViewModeChange('cards')}
	>
		<Icon icon="tabler:list" />
	</button>
	<button
		class="list-button"
		class:selected={viewMode === 'tickets'}
		on:click={() => handleViewModeChange('tickets')}
	>
		<Icon icon="tabler:ticket" />
	</button>
</div>

<style lang="scss">
	.main-wrapper {
		border: 1px solid var(--clr-border-primary);
		border-radius: var(--radius-1);
		background-color: var(--clr-neutral-badge);

		button {
			min-width: var(--space-10);
			min-height: var(--space-7);
			cursor: pointer;
			border: none;
			background-color: transparent;
			color: var(--clr-text-off);
			transition: all 0.3s ease-in-out;
			border-radius: var(--radius-0);
			align-items: center;
			justify-content: center;
			display: flex;

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
