<script lang="ts">
	import FloatTicket from '$lib/components/floats/FloatTicket.svelte';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import { unixTimeStampToDate } from '$lib/utilities/unixTimeStampToDate';

	export let float: FLOAT;
	let startDate: string;

	$: startDate = unixTimeStampToDate(float.dateReceived);
</script>

<div class="main-wrapper">
	<div class="top-wrapper">
		<div>
			<h4>{`#${float.eventId}`}</h4>
			<p class="small">Event ID</p>
		</div>
		<div>
			<h4>{float.totalSupply}</h4>
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
		gap: var(--space-8);
		padding: var(--space-6);

		.top-wrapper {
			display: flex;
			justify-content: space-around;
			align-items: center;
			text-align: center;
			width: 80%;

			h4 {
				color: var(--clr-text-main);
			}

			p {
				color: var(--clr-text-off);
			}
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
			width: 80%;

			.small {
				color: var(--clr-text-off);
			}
		}
	}
</style>
