<script lang="ts">
	import Icon from '@iconify/svelte';

	export let icon: string | undefined = undefined;
</script>

<h4>
	{#if icon}
		<Icon {icon} inline />
	{/if}
	<slot />
</h4>

<style lang="scss">
	h4 {
		font-size: var(--font-size-1);
		color: var(--clr-text-off);
		letter-spacing: 0.09em;
		text-transform: uppercase;
	}
</style>
