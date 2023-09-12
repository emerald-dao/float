<script lang="ts">
	import deleteEvent from '../../_actions/event-actions/deleteEvent';
	import toggleClaiming from '../../_actions/event-actions/toggleClaiming';
	import toggleTransfering from '../../_actions/event-actions/toggleTransfering';
	import Icon from '@iconify/svelte';
	import type { Event } from '$lib/types/event/event.interface';
	import DistributeFloatsModal from '$lib/features/bulk-distribute-floats/components/DistributeFloatsModal.svelte';
	import { invalidate } from '$app/navigation';
	import toggleVisibilityMode from '../../_actions/event-actions/toggleVisibilityMode';

	export let event: Event;

	let claimingState = event.claimable;
	let transferingState = event.transferrable;
	let certificateVisibility: boolean = event.visibilityMode === 'picture' ? false : true;

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

	const handleToggleVisibilityType = async () => {
		// For jacob!
		await toggleVisibilityMode(event.eventId);

		setTimeout(async () => {
			await invalidate('admin:specificEvent');
			certificateVisibility = event.visibilityMode === 'picture' ? false : true;
		}, 4000);
	};
</script>

<div class="main-wrapper">
	<div class="actions-wrapper">
		<div class="title-wrapper">
			<Icon icon="tabler:bolt" color="var(--clr-neutral-600)" />
			<p>ACTIONS</p>
		</div>
		<DistributeFloatsModal {event} />
	</div>
	<div class="toggles-wrapper">
		<div class="title-wrapper">
			<Icon icon="tabler:toggle-right" color="var(--clr-neutral-600)" />
			<p>SWITCHS</p>
		</div>
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
				<p class="small">Claiming active</p>
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
			<div class="row-3">
				<label for="visibility" class="switch">
					<input
						type="checkbox"
						name="visibility"
						id="visibility"
						bind:checked={certificateVisibility}
						on:change={handleToggleVisibilityType}
					/>
					<span class="slider" />
				</label>
				<p class="small">Certificate visibility</p>
			</div>
		</div>
	</div>
	<div class="danger-zone">
		<div class="title-wrapper">
			<Icon icon="tabler:alert-triangle" color="var(--clr-neutral-600)" />
			<p>DANGER ZONE</p>
		</div>
		<button on:click={() => deleteEvent(event.eventId)}>
			<Icon icon="ph:trash" color="var(--clr-alert-main)" />
			<p class="small" style="color: var(--clr-alert-main);">Delete Event</p>
		</button>
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		display: flex;
		flex-direction: column;
		justify-content: space-between;
		gap: var(--space-6);
		padding-inline: var(--space-6);
		flex: 1;

		@include mq(medium) {
			padding-inline: var(--space-8);
		}

		.title-wrapper {
			display: flex;
			flex-direction: row;
			gap: var(--space-1);
			align-items: center;

			p {
				color: var(--clr-text-off);
				font-size: var(--font-size-1);
				letter-spacing: 0.07em;
			}
		}

		.actions-wrapper,
		.toggles-wrapper,
		.danger-zone {
			display: flex;
			flex-direction: column;
			align-items: flex-start;
			gap: var(--space-3);
		}

		.danger-zone {
			button {
				background-color: transparent;
				border: none;
				padding: 0;
				display: flex;
				flex-direction: row;
				gap: var(--space-1);
				align-items: center;
				cursor: pointer;
				margin: 0;
			}
		}
	}
</style>
