<script lang="ts">
	import Icon from '@iconify/svelte';

	export let name: string;
	export let icon: string;
</script>

<div class="card-primary">
	<span class="row-1 align-center">
		<Icon {icon} />
		{name}
	</span>
	<slot />
</div>

<style lang="scss">
	.card-primary {
		padding: var(--space-4);
	}
</style>
