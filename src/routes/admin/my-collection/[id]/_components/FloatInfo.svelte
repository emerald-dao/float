<script lang="ts">
	import { fly } from 'svelte/transition';
	import Float from '$lib/components/floats/Float.svelte';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import { unixTimestampToFormattedDate } from '$lib/utilities/dates/unixTimestampToFormattedDate';
	import Blur from '$lib/components/Blur.svelte';

	export let float: FLOAT;
</script>

<div class="main-wrapper">
	<Blur color="tertiary" right="0" top="30%" diameter="12rem" />
	<Blur left="0" bottom="20%" diameter="12rem" />
	<div class="top-wrapper">
		<div>
			<p class="large">{`#${float.id}`}</p>
			<p class="small">FLOAT ID</p>
		</div>
		<div>
			<p class="large">{float.serial}</p>
			<p class="small">Serial</p>
		</div>
	</div>
	<div class="ticket-wrapper" in:fly={{ duration: 400, x: 180 }}>
		<Float {float} />
	</div>
	<div class="details-wrapper">
		<div>
			<p class="large">{unixTimestampToFormattedDate(float.dateReceived)}</p>
			<p class="small">Date Minted</p>
		</div>
		<div class="price">
			<p class="large">{float.originalRecipient}</p>
			<p class="small">Original Recipient</p>
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
		overflow: visible;
		position: relative;

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
			overflow: visible;
			display: flex;
			justify-content: center;
			align-items: center;
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
