<script lang="ts">
	import Icon from '@iconify/svelte';

	export let name: string;
	export let status: 'locked' | 'unlocked' | 'expired' | 'soldout' | 'available';
	export let message: string;
	export let icon: string;

	const STATUS_COLOR_MAP = {
		unlocked: 'primary',
		expired: 'alert',
		locked: 'neutral',
		soldout: 'alert',
		available: 'primary'
	};
</script>

<div class="main-wrapper">
	<span class="verifier-title row-1 align-center xsmall">
		<Icon {icon} />
		{name}
	</span>
	<span
		class="verifier-state row-1 align-center xsmall"
		style={`color: var(--clr-${STATUS_COLOR_MAP[status]}-main);`}
	>
		<Icon
			icon="tabler:circle-filled"
			width="0.6em"
			color={`var(--clr-${STATUS_COLOR_MAP[status]}-main)`}
		/>
		{message}
	</span>
</div>

<style lang="scss">
	.main-wrapper {
		border-radius: var(--radius-1);
		overflow: hidden;
		border: 1px dashed var(--clr-border-primary);
		flex: 1;
		width: fit-content;

		.verifier-title {
			border-bottom: 1px dashed var(--clr-border-primary);
			// don't break line text
			white-space: nowrap;
			overflow: hidden;
		}

		.verifier-title,
		.verifier-state {
			padding: var(--space-1) var(--space-3);
		}
	}
</style>
