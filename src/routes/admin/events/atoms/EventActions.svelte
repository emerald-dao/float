<script lang="ts">
	import deleteEvent from '../../_actions/event-actions/deleteEvent';
	import toggleClaiming from '../../_actions/event-actions/toggleClaiming';
	import toggleTransfering from '../../_actions/event-actions/toggleTransfering';
	import Icon from '@iconify/svelte';
	import type { EventWithStatus } from '$lib/types/event/event.interface';
	import DistributeFloatsModal from '$lib/features/bulk-distribute-floats/components/DistributeFloatsModal.svelte';
	import toggleVisibilityMode from '../../_actions/event-actions/toggleVisibilityMode';
	import { getContext } from 'svelte';
	import type createFetchStore from '../../_stores/fetchStore';
	import EventDataTitle from '../_components/EventDataTitle.svelte';
	import DownloadEmailsButton from '../_components/DownloadEmailsButton.svelte';
	import DownloadClaimersButton from '../_components/DownloadClaimersButton.svelte';

	export let event: EventWithStatus;

	const eventsStore: ReturnType<typeof createFetchStore> = getContext('events');

	let claimingState = event.claimable;
	let transferingState = event.transferrable;
	let certificateVisibility: boolean = event.visibilityMode === 'picture' ? false : true;

	const handleToggleClaiming = async () => {
		claimingState = !claimingState;
		await toggleClaiming(event.eventId);

		eventsStore.invalidate();

		setTimeout(() => {
			claimingState = event.claimable;
		}, 1000);
	};

	const handleToggleTransfering = async () => {
		transferingState = !transferingState;
		await toggleTransfering(event.eventId);

		eventsStore.invalidate();

		setTimeout(() => {
			transferingState = event.transferrable;
		}, 1000);
	};

	const handleToggleVisibilityType = async () => {
		certificateVisibility = !certificateVisibility;
		await toggleVisibilityMode(event.eventId);

		eventsStore.invalidate();

		setTimeout(() => {
			certificateVisibility = event.visibilityMode === 'picture' ? false : true;
		}, 1000);
	};
</script>

<div class="main-wrapper">
	<div class="actions-wrapper">
		<EventDataTitle icon="tabler:bolt">Actions</EventDataTitle>
		<DistributeFloatsModal {event} />
		<DownloadClaimersButton eventHost={event.host} eventId={event.eventId} />
		{#if event.verifiers.requireEmail != undefined}
			<DownloadEmailsButton eventId={event.eventId} />
		{/if}
	</div>
	<div class="toggles-wrapper">
		<EventDataTitle icon="tabler:toggle-right">Switchs</EventDataTitle>
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
		<EventDataTitle icon="tabler:alert-triangle">Danger zone</EventDataTitle>
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
