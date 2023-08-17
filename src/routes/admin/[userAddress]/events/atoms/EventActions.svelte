<script lang="ts">
	import deleteEvent from '../../_actions/event-actions/deleteEvent';
	import toggleClaiming from '../../_actions/event-actions/toggleClaiming';
	import toggleTransfering from '../../_actions/event-actions/toggleTransfering';
	import { Button } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';
	import type { Event } from '$lib/types/event/event.interface';

	export let event: Event;
</script>

<div class="main-wrapper">
	<div class="row-1">
		<Icon icon="uil:bolt-alt" color="var(--clr-neutral-600)" />
		<p>ACTIONS</p>
	</div>
	<div class="column-3">
		<div class="row-3">
			<label for="claiming" class="switch">
				<input
					type="checkbox"
					name="claiming"
					id="claiming"
					on:change={() => toggleClaiming(event.eventId)}
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
					on:change={() => toggleTransfering(event.eventId)}
				/>
				<span class="slider" />
			</label>
			<p class="small">User transfering</p>
		</div>
	</div>
	<div class="event-actions">
		<Button type="transparent" on:click={() => deleteEvent(event.eventId)}>
			<Icon icon="ph:trash" color="var(--clr-alert-main)" />
			<p style="color: var(--clr-alert-main);">Delete Event</p>
		</Button>
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		display: flex;
		flex-direction: column;
		gap: var(--space-3);
		padding-inline: var(--space-6);

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

	.event-actions {
		display: flex;
		align-items: center;
		justify-content: flex-start;
		gap: var(--space-5);
	}
</style>
