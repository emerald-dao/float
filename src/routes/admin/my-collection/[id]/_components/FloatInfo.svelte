<script lang="ts">
	import { fly } from 'svelte/transition';
	import FloatTicket from '$lib/components/floats/FloatTicket.svelte';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import { unixTimestampToFormattedDate } from '$lib/utilities/dates/unixTimestampToFormattedDate';

	export let float: FLOAT;
	let startDate: string;

	$: startDate = unixTimestampToFormattedDate(float.dateReceived);
</script>

<div class="main-wrapper">
	<div class="top-wrapper">
		<div>
			<p class="large">{`#${float.eventId}`}</p>
			<p class="small">Event ID</p>
		</div>
		<div>
			<p class="large">{float.totalSupply}</p>
			<p class="small">FLOATs claimed</p>
		</div>
	</div>
	<div class="ticket-wrapper">
		<FloatTicket {float} />
	</div>
	<div class="details-wrapper">
		<div>
			<p class="large">{startDate}</p>
			<p class="small">Start Date</p>
		</div>
		<div class="price">
			<!-- This is temporary, whe should change the hardcoded price-->
			<p class="large">Free(temporary)</p>
			<p class="small">Price</p>
		</div>
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		display: flex;
		flex-direction: column;
		justify-content: center;
		align-items: center;
		gap: var(--space-12);
		padding: var(--space-8) var(--space-15);
		height: 100%;

		.top-wrapper {
			display: flex;
			justify-content: space-between;
			width: 100%;
			gap: var(--space-4);
			align-items: center;
			text-align: center;
		}

		.ticket-wrapper {
			width: 100%;
		}

		.details-wrapper {
			display: grid;
			grid-template-columns: repeat(2, 1fr);
			justify-content: center;
			align-items: center;
			text-align: center;
			gap: var(--space-6);
			border-top: 1px dashed var(--clr-border-primary);
			border-bottom: 1px dashed var(--clr-border-primary);
			padding: var(--space-5) 0 var(--space-5) 0;
			width: 100%;
		}

		p.small {
			color: var(--clr-text-off);
		}

		p.large {
			color: var(--clr-text-primary);
		}
	}
</style>
