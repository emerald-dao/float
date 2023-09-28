<script lang="ts">
	import { Label } from '@emerald-dao/component-library';

	export let title: string;
	export let type: string;
	export let qrUrl: string;
	export let eventUrl: string;
	export let clickable: boolean = false;
</script>

{#if clickable}
	<a href={eventUrl}>
		<div class="card column-8 center">
			<div class="column-3 center">
				<span class="subheading small">FLOAT Attendance Claim</span>
				<h4 class="h5">{title}</h4>
				<Label color="neutral">
					{type}
				</Label>
			</div>
			<img src={qrUrl} alt="event qr code" />
		</div>
	</a>
{:else}
	<div class="card column-8 center">
		<div class="column-3 center">
			<span class="subheading small">FLOAT Attendance Claim</span>
			<h4 class="h5">{title}</h4>
			<Label color="neutral">
				{type}
			</Label>
		</div>
		<img src={qrUrl} alt="event qr code" />
	</div>
{/if}

<style lang="scss">
	a {
		text-decoration: none;
		cursor: pointer;
	}
	.card {
		padding: var(--space-12);
		max-width: 300px;
		background-color: var(--clr-background-secondary);

		.subheading {
			color: var(--clr-primary-main);
			text-align: center;
		}

		h4 {
			text-align: center;
		}
	}
</style>
