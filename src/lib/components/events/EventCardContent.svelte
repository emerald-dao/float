<script lang="ts">
	import type { EventWithStatus } from '$lib/types/event/event.interface';
	import { Label } from '@emerald-dao/component-library';
	import EventStatus from './EventStatus.svelte';
	import TimelockStateLabel from '$lib/features/event-status-management/components/TimelockStateLabel.svelte';
	import LimitedStateLabel from '$lib/features/event-status-management/components/LimitedStateLabel.svelte';

	export let event: EventWithStatus;
	export let display: 'grid' | 'list' = 'list';
	export let displayedInAdmin = true;
</script>

<div class={`main-wrapper ${display}`}>
	<div class={`general-info-wrapper `}>
		<div class="title-wrapper row-3">
			<img src={event.image} width="55px" height="55px" alt="logo" />
			<div class="name-wrapper">
				<p class="w-medium">{event.name}</p>
				<Label size="xx-small" color="neutral" hasBorder={false}>{event.eventType}</Label>
			</div>
		</div>
		<div
			class="minted-floats-wrapper"
			class:no-extra-info={display === 'list' && !displayedInAdmin}
		>
			<span class="w-medium">
				{Number(event.totalSupply).toLocaleString()} FLOATs
			</span>
			<span class="small"> claimed </span>
		</div>
	</div>
	<div class="secondary-wrapper">
		<div class="status-wrapper column-1">
			<EventStatus status={event.status.generalStatus} />
		</div>
		{#if event.status.verifiersStatus && (event.status.verifiersStatus.timelockStatus !== null || event.status.verifiersStatus.limitedStatus !== null)}
			<div class="powerups-wrapper" class:no-extra-info={display === 'list' && !displayedInAdmin}>
				{#if event.status.verifiersStatus.timelockStatus}
					<TimelockStateLabel timelockStatus={event.status.verifiersStatus.timelockStatus} />
				{/if}
				{#if event.status.verifiersStatus.limitedStatus}
					<LimitedStateLabel limitedStatus={event.status.verifiersStatus.limitedStatus} />
				{/if}
			</div>
		{/if}
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		display: flex;
		flex-direction: column;
		justify-content: space-between;
		gap: var(--space-6);
		border: 1px solid var(--clr-border-primary);
		border-radius: var(--radius-2);
		width: 100%;
		transition: 300ms ease-in-out;
		background-color: var(--clr-surface-primary);

		&:hover {
			background: var(--clr-surface-secondary);
			box-shadow: 0px 2px 6px 0 var(--clr-shadow-primary);
		}

		.general-info-wrapper {
			display: flex;
			flex-direction: column;
			justify-content: center;
			gap: var(--space-7);
			padding: var(--space-8) var(--space-8) 0px var(--space-8);

			.title-wrapper {
				align-items: center;

				img {
					border-radius: var(--radius-0);
				}

				.name-wrapper {
					p {
						text-align: left;
						color: var(--clr-heading-main);
						font-size: var(--font-size-2);
					}

					span {
						text-align: center;
						width: fit-content;
						border: var(--border-width-primary) solid var(--clr-border-primary);
						padding: var(--space-1);
						border-radius: var(--radius-1);
					}
				}
			}
		}

		.secondary-wrapper {
			display: flex;
			align-items: flex-start;
			border-top: 1px dashed var(--clr-border-primary);
			padding-inline: var(--space-2);

			.powerups-wrapper {
				border-left: 1px dashed var(--clr-border-primary);
				padding-inline: var(--space-4);
				height: 100%;
				display: flex;
				flex-direction: row;
				gap: var(--space-3);
			}

			.status-wrapper,
			.powerups-wrapper {
				padding: var(--space-5);
			}
		}

		&.list {
			flex-direction: row;
			padding: var(--space-1) var(--space-6);

			.no-extra-info {
				display: none;
			}

			.general-info-wrapper {
				padding: 0;
				flex-direction: row;
				align-items: center;
				gap: var(--space-12);
			}

			.secondary-wrapper {
				flex-direction: row-reverse;
				align-items: center;
				border-top: none;
				padding: 0;

				.powerups-wrapper {
					border-right: 1px dashed var(--clr-border-primary);
					height: 100%;
					border-left: none;
				}
			}
		}
	}
</style>
