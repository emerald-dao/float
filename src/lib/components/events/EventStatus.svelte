<script lang="ts">
	import type { EventGeneralStatus } from '$lib/types/event/event.interface';

	export let status: EventGeneralStatus;
	export let claimability: boolean;

	const STATUS_COLOR_MAP: {
		[key in EventGeneralStatus]: 'primary' | 'alert' | 'neutral';
	} = {
		available: 'primary',
		soldout: 'alert',
		paused: 'alert',
		expired: 'alert',
		locked: 'neutral'
	};
</script>

<div class="main-wrapper">
	<span class="title xsmall">Status</span>
	<div
		class="state-wrapper column"
		style={`background-color: var(--clr-${STATUS_COLOR_MAP[status]}-badge)`}
	>
		<span class="small" style={`color: var(--clr-${STATUS_COLOR_MAP[status]}-main)`}>
			{status.charAt(0).toUpperCase() + status.slice(1)}
		</span>
		{#if status === 'available'}
			{#if !claimability}
				<span class="xsmall" style={`color: var(--clr-text-off)`}> Non-claimable </span>
			{:else}
				<span class="xsmall" style={`color: var(--clr-text-off)`}> Claimable </span>
			{/if}
		{/if}
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		border: 1px solid var(--clr-border-primary);
		border-radius: var(--radius-1);
		flex: 1;
		text-align: center;

		.state-wrapper {
			border-top: 1px solid var(--clr-border-primary);
		}

		.title,
		.state-wrapper {
			text-align: center;
			padding: var(--space-1) var(--space-3);
		}
	}
</style>
