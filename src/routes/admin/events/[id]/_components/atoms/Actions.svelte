<script>
	import { Button } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';
</script>

<div class="domains-wrapper">
	<div class="row-1">
		<Icon icon="uil:bolt-alt" color="var(--clr-neutral-600)" />
		<p>ACTIONS</p>
	</div>
	<div class="column-3">
		<div class="row-3">
			<label for="claiming" class="switch">
				<input type="checkbox" name="claiming" id="claiming" />
				<span class="slider" />
			</label>
			<p class="small">Claiming ative</p>
		</div>
		<div class="row-3">
			<label for="other" class="switch">
				<input type="checkbox" name="other" id="other" />
				<span class="slider" />
			</label>
			<p class="small">Other option</p>
		</div>
		<div class="row-3">
			<label for="transfering" class="switch">
				<input type="checkbox" name="transfering" id="transfering" />
				<span class="slider" />
			</label>
			<p class="small">User transfering</p>
		</div>
	</div>
	<div class="event-actions">
		<Button type="transparent">
			<Icon icon="ph:trash" color="var(--clr-alert-main)" />
			<p style="color: var(--clr-alert-main);">Delete Event</p>
		</Button>
		<Button type="transparent">
			<Icon icon="ph:archive-bold" color="var(--clr-text-main)" />
			<p style="color: var(--clr-text-main);">Archive Event</p>
		</Button>
	</div>
</div>

<style type="scss">
	.domains-wrapper {
		display: flex;
		flex-direction: column;
		gap: var(--space-3);

		.row-1 {
			align-items: center;
			p {
				color: var(--clr-text-off);
			}
		}

		.column-3 {
			border-bottom: 1px dashed var(--clr-border-primary);
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
