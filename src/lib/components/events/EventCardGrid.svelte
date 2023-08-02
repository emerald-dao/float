<script lang="ts">
	import type { Event } from '$lib/types/event/event.interface';
	import { Label } from '@emerald-dao/component-library';
	import { onMount } from 'svelte';
	import type { VerifiersStatus } from '$lib/features/verifiers/types/verifiers-status.interface';
	import { getVerifiersState } from '$lib/features/verifiers/functions/getVerifiersState';
	import TimelockStateLabel from '$lib/features/components/TimelockStateLabel.svelte';
	import LimitedStateLabel from '$lib/features/components/LimitedStateLabel.svelte';
	import EventStatus from './EventStatus.svelte';

	export let event: Event;

	let verifiersStatus: VerifiersStatus;

	onMount(() => {
		verifiersStatus = getVerifiersState(event.verifiers, Number(event.totalSupply));
	});

	$: mainImage = event.eventImage || '/test-toucan.png';
</script>

<a class="main-wrapper" href={`/admin/events/${event.eventId}`}>
	<img src={mainImage} alt="Event image" class="main-image" />
	<div class="top-wrapper">
		<div class="row-3 details-wrapper">
			<img src={event.image} width="55px" height="55px" alt="logo" />
			<div class="column-1">
				<p class="w-medium">{event.name}</p>
				<Label size="xx-small" color="neutral" hasBorder={false}>{event.eventType}</Label>
			</div>
		</div>
		<div>
			<span class="w-medium">
				{event.totalSupply} FLOATs
			</span>
			<span class="small"> claimed </span>
		</div>
	</div>
	<div class="bottom-wrapper">
		<div class="status-wrapper column-1">
			<EventStatus status={event.claimable} />
		</div>
		<div class="powerups-wrapper">
			{#if verifiersStatus}
				{#if verifiersStatus.timelockStatus}
					<TimelockStateLabel timelockStatus={verifiersStatus.timelockStatus} />
				{/if}
				{#if verifiersStatus.limitedStatus}
					<LimitedStateLabel limitedStatus={verifiersStatus.limitedStatus} />
				{/if}
				{#if verifiersStatus.timelockStatus === null && verifiersStatus.limitedStatus === null}
					<span class="xsmall"> No active powerups </span>
				{/if}
			{/if}
		</div>
	</div>
</a>

<style lang="scss">
	a {
		text-decoration: none;
		color: unset;
		word-break: break-word;
	}

	.main-wrapper {
		display: flex;
		flex-direction: column;
		justify-content: space-between;
		gap: var(--space-6);
		border: 1px solid var(--clr-border-primary);
		border-radius: var(--radius-2);
		transition: 300ms ease-in-out;
		overflow: hidden;
		background-color: var(--clr-surface-primary);

		&:hover {
			background: var(--clr-surface-secondary);
			box-shadow: 0px 2px 6px 0 var(--clr-shadow-primary);
		}

		.main-image {
			width: 100%;
			height: 100px;
			object-fit: cover;
			border-bottom: 0.5px solid var(--clr-border-primary);
		}

		.top-wrapper {
			display: flex;
			flex-direction: column;
			justify-content: center;
			gap: var(--space-7);
			padding: 0 var(--space-8) 0;

			.details-wrapper {
				align-items: center;

				img {
					border-radius: var(--radius-0);
				}

				.column-1 {
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

		.bottom-wrapper {
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
	}
</style>
