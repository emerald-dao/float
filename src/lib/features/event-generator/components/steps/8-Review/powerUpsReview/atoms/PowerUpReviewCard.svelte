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
		padding: var(--space-4);
		background-color: transparent;
		border-radius: var(--radius-2);
		background-color: var(--clr-background-primary);

		span {
			margin-bottom: var(--space-2);
		}
	}
</style>
