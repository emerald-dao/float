<script lang="ts">
	import Blur from '$lib/components/Blur.svelte';
	import FloatTicket from '$lib/components/floats/FloatTicket.svelte';
	import { Button } from '@emerald-dao/component-library';
	import { onMount } from 'svelte';
	import claimFloat from '../../../../routes/event/_actions/claimFloat';
	import transformEventToFloat from '$lib/utilities/transformEventToFloat';
	import { unixTimeStampToDate } from '$lib/utilities/unixTimeStampToDate';

	export let data;

	let noDates = false;
	let starDate: string;
	let endDate: string;
	let dates = {};

	data.overview.verifiers.forEach((verifier) => {
		if (verifier.dateStart) {
			dates.dateStart = verifier.dateStart;
		}
		if (verifier.dateEnding) {
			dates.dateEnding = verifier.dateEnding;
		}
	});

	if (dates.dateStart && dates.dateEnding) {
		starDate = unixTimeStampToDate(dates.dateStart);
		endDate = unixTimeStampToDate(dates.dateEnding);
	}

	onMount(() => {
		noDates = data.overview.verifiers.every(
			(verifier) => !('dateStart' in verifier && 'dateEnding' in verifier)
		);
	});
</script>

<section class="container">
	<div class="main-wrapper">
		<div class="side-wrapper">
			<h4>{`#${data.overview.eventId}`}</h4>
			<p class="small">Event ID</p>
		</div>
		<div class="event-wrapper">
			<Blur color="tertiary" right="15%" top="10%" />
			<Blur left="15%" top="10%" />
			<FloatTicket float={transformEventToFloat(data.overview)} />
		</div>
		<div class="side-wrapper">
			<h4>{`${data.overview.totalSupply}`}</h4>
			<p class="small">FLOATs claimed</p>
		</div>
	</div>
	<div class="container-small details-wrapper {noDates ? 'two-columns' : ''}">
		{#if starDate && endDate}
			<div>
				<p class="large">{starDate}</p>
				<p class="small">Start Date</p>
			</div>
			<div>
				<p class="large">{endDate}</p>
				<p class="small">End Date</p>
			</div>
		{:else}
			<div>
				<p class="large">{data.overview.dateCreated}</p>
				<p class="small">Start Date</p>
			</div>
		{/if}
		<div>
			{#if !data.overview.price}
				<p class="large">Free</p>
			{:else}
				<p class="large">USD {data.overview.price}</p>
			{/if}
			<p class="small">Price</p>
		</div>
	</div>
	<Button size="medium" width="extended" on:click={() => claimFloat()}><p>Claim FLOAT</p></Button>
</section>

<style lang="scss">
	section {
		position: relative;
		display: flex;
		flex-direction: column;
		align-items: center;
		gap: var(--space-13);

		.main-wrapper {
			display: flex;
			justify-content: center;
			align-items: center;
			text-align: center;
			gap: var(--space-16);

			.side-wrapper {
				display: none;

				@include mq(medium) {
					display: block;
					h4 {
						color: var(--clr-text-main);
					}

					p {
						color: var(--clr-text-off);
					}
				}
			}

			.event-wrapper {
				display: flex;
				flex-direction: column;
				justify-content: center;
				align-items: center;
			}
		}

		.details-wrapper {
			display: grid;
			grid-template-columns: repeat(3, 1fr);
			text-align: center;
			border-top: 1px dashed var(--clr-border-primary);
			border-bottom: 1px dashed var(--clr-border-primary);
			padding: var(--space-5) 0 var(--space-5) 0;

			&.two-columns {
				grid-template-columns: repeat(2, 1fr);
			}

			.small {
				color: var(--clr-text-off);
			}
		}
	}
</style>
