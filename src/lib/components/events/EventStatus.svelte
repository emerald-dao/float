<script lang="ts">
	import type {
		LimitedStatus,
		TimelockStatus
	} from '$lib/features/event-status-management/types/verifiers-status.interface';
	import type { EventGeneralStatus } from '$lib/types/event/event.interface';

	export let status: EventGeneralStatus;
	export let claimability: boolean;
	export let timelockStatus: TimelockStatus;
	export let limitedStatus: LimitedStatus;

	const STATUS_COLOR_MAP: {
		[key in EventGeneralStatus]: 'primary' | 'alert' | 'neutral';
	} = {
		available: 'primary',
		soldout: 'alert',
		expired: 'alert',
		locked: 'neutral'
	};

	const STATUS_MESSAGE_MAP: {
		[key in EventGeneralStatus]: string;
	} = {
		available: 'Available',
		soldout: 'Sold Out',
		expired: 'Expired',
		locked: 'Not Started'
	};
</script>

<div class="main-wrapper card">
	<div class="title-wrapper">
		<span class="title w-medium">Status</span>
	</div>
	<div
		class="state-wrapper column"
		style={`background-color: var(--clr-${STATUS_COLOR_MAP[status]}-badge)`}
	>
		<span
			class="state xsmall w-medium"
			style={`color: var(--clr-${STATUS_COLOR_MAP[status]}-main)`}
		>
			{STATUS_MESSAGE_MAP[status]}
		</span>
	</div>
	{#if status === 'available'}
		<div
			class="details-wrapper"
			style={`background-color: var(--clr-${STATUS_COLOR_MAP[status]}-badge)`}
		>
			{#if !claimability}
				<span class="xsmall w-medium"> Non-claimable </span>
			{:else}
				<span class="xsmal w-medium"> Claimable </span>
			{/if}
		</div>
	{/if}
	{#if status === 'locked'}
		<div
			class="details-wrapper"
			style={`background-color: var(--clr-${STATUS_COLOR_MAP[status]}-badge)`}
		>
			<span class="xsmall w-medium">
				{`Starts in ${timelockStatus?.remainingTime} days`}
			</span>
		</div>
	{/if}
</div>

<style lang="scss">
	.main-wrapper {
		border: 1px solid var(--clr-neutral-badge);
		border-radius: var(--radius-1);
		text-align: center;
		overflow: hidden;
		padding: 0;

		.title-wrapper {
			background-color: var(--clr-surface-primary);
			display: flex;
			justify-content: center;
			padding-block: var(--space-1);

			.title {
				color: var(--clr-text-off);
				font-size: 0.65em;
				line-height: 1;
			}
		}

		.state-wrapper {
			padding-block: var(--space-2);
			border-top: 1px dashed var(--clr-neutral-badge);
		}

		.title-wrapper,
		.state-wrapper {
			padding-inline: var(--space-7);
		}
	}

	.details-wrapper {
		border-top: 1px dashed var(--clr-neutral-badge);
		display: flex;
		justify-content: center;
		padding: 0.2em;

		span {
			font-size: 0.6em;
			line-height: 1;
			color: var(--clr-text-off);
		}
	}
</style>
