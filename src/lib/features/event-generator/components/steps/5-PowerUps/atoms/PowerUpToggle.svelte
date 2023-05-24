<script lang="ts">
	import Icon from '@iconify/svelte';

	export let name: string;
	export let active: boolean;
</script>

<span on:click class="row-2 align-center" class:active>
	<Icon icon="tabler:cash" />
	{name}
</span>

<style lang="scss">
	span {
		background-color: var(--clr-neutral-badge);
		border: 1px solid var(--clr-border-primary);
		width: fit-content;
		padding: var(--space-1) var(--space-3);
		border-radius: var(--radius-3);

		&.active {
			background-color: var(--clr-primary-badge);
			color: var(--clr-primary-main);
			border-color: var(--clr-primary-main);
		}
	}
</style>
