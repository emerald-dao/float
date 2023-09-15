<script lang="ts">
	import Icon from '@iconify/svelte';

	export let name: string;
	export let icon: string;
</script>

<div class="card">
	<span class="row-1 align-center w-medium small">
		<Icon {icon} />
		{name}
	</span>
	<slot />
</div>

<style lang="scss">
	.card {
		display: flex;
		flex-direction: column;
		justify-content: space-around;
		padding: 0;
		background-color: transparent;
		border-radius: var(--radius-2);
		background-color: var(--clr-background-primary);
		height: 100%;

		span {
			padding: var(--space-1) var(--space-4);
			border-bottom: 1px dashed var(--clr-border-primary);
		}
	}
</style>
