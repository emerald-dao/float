<script lang="ts">
	import Icon from '@iconify/svelte';

	export let showInactive: boolean;

	const toggleInactive = () => {
		showInactive = !showInactive;
	};
</script>

<div>
	<button on:click={toggleInactive} class:selected={showInactive}>
		{#if showInactive}
			<Icon icon="tabler:eye" />
		{:else}
			<Icon icon="tabler:eye-off" />
		{/if}
		Claimable events
	</button>
</div>

<style lang="scss">
	div {
		border: 1px solid var(--clr-border-primary);
		border-radius: var(--radius-1);
		background-color: var(--clr-neutral-badge);

		button {
			border-radius: var(--radius-0);
			background-color: transparent;
			border: none;
			cursor: pointer;
			font-size: var(--font-size-1);
			display: flex;
			align-items: center;
			justify-content: center;
			white-space: nowrap;
			text-align: center;
			gap: var(--space-1);
			padding: var(--space-1) var(--space-3);
			margin: var(--space-1);
			transition: all 0.3s ease-in-out;
			color: var(--clr-text-off);
		}

		button.selected {
			color: var(--clr-heading-main);
			background-color: var(--clr-surface-primary);
			box-shadow: 0px 2px 6px 0 var(--clr-shadow-primary);
		}
	}
</style>
