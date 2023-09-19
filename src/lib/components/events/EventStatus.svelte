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

<div class="main-wrapper card">
	<div class="title-wrapper">
		<span class="title xsmall w-medium">Event status</span>
	</div>
	<div
		class="state-wrapper column"
		style={`background-color: var(--clr-${STATUS_COLOR_MAP[status]}-badge)`}
	>
		<span class="state small w-medium" style={`color: var(--clr-${STATUS_COLOR_MAP[status]}-main)`}>
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
		border: 1px solid var(--clr-neutral-badge);
		border-radius: var(--radius-1);
		text-align: center;
		overflow: hidden;
		padding: 0;

		.title-wrapper {
			background-color: var(--clr-surface-secondary);

			.title {
				color: var(--clr-text-off);
			}
		}

		.state-wrapper {
			text-align: center;
			padding-block: var(--space-1);
			border-top: 1px dashed var(--clr-neutral-badge);
		}

		.title-wrapper,
		.state-wrapper {
			padding-inline: var(--space-5);
		}
	}
</style>
