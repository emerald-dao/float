<script lang="ts">
	import { page } from '$app/stores';
	import deleteEvent from '../../_actions/event-actions/deleteEvent';
	import toggleClaiming from '../../_actions/event-actions/toggleClaiming';
	import toggleTransfering from '../../_actions/event-actions/toggleTransfering';
	import { Button } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';
	import type { Event } from '$lib/types/event/event.interface';
	import DistributeFloatsModal from '$lib/features/bulk-distribute-floats/components/DistributeFloatsModal.svelte';
	import { invalidate } from '$app/navigation';

	export let event: Event;

	let claimingState = event.claimable;
	let transferingState = event.transferrable;

	const handleToggleClaiming = async () => {
		await toggleClaiming(event.eventId);

		setTimeout(async () => {
			await invalidate('admin:specificEvent');
			claimingState = event.claimable;
		}, 4000);
	};

	const handleToggleTransfering = async () => {
		await toggleTransfering(event.eventId);

		setTimeout(async () => {
			await invalidate('admin:specificEvent');
			transferingState = event.transferrable;
		}, 4000);
	};
</script>

<div class="main-wrapper">
	<div class="row-1">
		<Icon icon="uil:bolt-alt" color="var(--clr-neutral-600)" />
		<p>ACTIONS</p>
	</div>
	<div class="actions-wrapper">
		<div class="column-3">
			<div class="row-3">
				<label for="claiming" class="switch">
					<input
						type="checkbox"
						name="claiming"
						id="claiming"
						bind:checked={claimingState}
						on:change={handleToggleClaiming}
					/>
					<span class="slider" />
				</label>
				<p class="small">Claiming ative</p>
			</div>
			<div class="row-3">
				<label for="transfering" class="switch">
					<input
						type="checkbox"
						name="transfering"
						id="transfering"
						bind:checked={transferingState}
						on:change={handleToggleTransfering}
					/>
					<span class="slider" />
				</label>
				<p class="small">User transfering</p>
			</div>
			<DistributeFloatsModal />
		</div>
		<div class="event-actions">
			<Button type="transparent" on:click={() => deleteEvent(event.eventId)}>
				<Icon icon="ph:trash" color="var(--clr-alert-main)" />
				<p style="color: var(--clr-alert-main);">Delete Event</p>
			</Button>
		</div>
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		display: flex;
		flex-direction: column;
		gap: var(--space-3);
		padding-inline: var(--space-6);
		flex: 1;

		@include mq(medium) {
			padding-inline: var(--space-8);
		}

		.row-1 {
			align-items: center;
			p {
				color: var(--clr-text-off);
			}
		}

		.column-3 {
			// border-bottom: 1px dashed var(--clr-border-primary);
			padding-bottom: var(--space-6);
		}
	}

	.actions-wrapper {
		display: flex;
		flex-direction: column;
		gap: var(--space-3);
		justify-content: space-between;
		flex: 1;

		.event-actions {
			display: flex;
			align-items: center;
			justify-content: flex-start;
			gap: var(--space-5);
		}
	}
</style>
