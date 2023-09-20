<script lang="ts">
	import type { EventGeneralStatus } from '$lib/types/event/event.interface';
	import Icon from '@iconify/svelte';

	export let name: string;
	export let specificStatus: 'locked' | 'unlocked' | 'expired' | 'soldout' | 'available';
	export let generalStatus: EventGeneralStatus;
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
	<div class="verifier-state-wrapper">
		<span
			class="verifier-state row-1 align-center xsmall"
			class:available={generalStatus === 'available'}
			style={`color: var(--clr-${STATUS_COLOR_MAP[specificStatus]}-main);`}
		>
			<Icon
				icon="tabler:circle-filled"
				width="0.6em"
				color={`var(--clr-${STATUS_COLOR_MAP[specificStatus]}-main)`}
			/>
			{message}
		</span>
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		border-radius: var(--radius-1);
		overflow: hidden;
		border: 1px dashed var(--clr-border-primary);
		flex: 1;
		width: fit-content;
		text-align: center;

		.verifier-title {
			border-bottom: 1px dashed var(--clr-border-primary);
			// don't break line text
			white-space: nowrap;
			overflow: hidden;
			padding: var(--space-1) var(--space-3);
		}

		.verifier-state-wrapper {
			display: flex;
			justify-content: center;
			.verifier-state {
				padding: var(--space-1) var(--space-3);

				&.available {
					padding: 12.5px var(--space-3);
				}
			}
		}
	}
</style>
