<script lang="ts">
	import type { FLOAT } from '$lib/types/float/float.interface';
	import FloatMedalAndCertificateFront from './atoms/FloatMedalAndCertificateFront.svelte';

	export let float: FLOAT;
	export let isForScreenshot = false; // When true, the float will be rendered without some details (e.g. Recipient and Float Serial )
	export let hasBorder = false;
</script>

<div class="float-front" class:dashed-border={hasBorder}>
	<div class="top-right-triangle" />
	<div class="top-left-triangle" />
	<div class="bottom-right-triangle" />
	<div class="bottom-left-triangle" />
	<FloatMedalAndCertificateFront {float} {isForScreenshot} />
</div>

<style lang="scss">
	.float-front {
		position: absolute;
		width: 100%;
		height: 100%;
		-webkit-backface-visibility: hidden; /* Safari */
		backface-visibility: hidden;
		top: 0;
		border-radius: 2em;
		background: var(--clr-surface-secondary);
		padding: 5% 7%;
		width: 100%;
		height: 100%;
		overflow: hidden;

		&.dashed-border:before {
			position: absolute;
			content: '';
			display: block;
			bottom: 0;
			top: 0;
			left: 0;
			width: 0;
			border-left: 1px dashed var(--clr-border-primary);
		}
	}

	.bottom-right-triangle,
	.bottom-left-triangle,
	.top-right-triangle,
	.top-left-triangle {
		content: '';
		position: absolute;
		border-color: transparent;
		border-style: solid;
		border-width: 1.95em;
	}

	.bottom-right-triangle {
		bottom: 0;
		right: 0;
		border-right-color: var(--clr-primary-badge);
		border-bottom-color: var(--clr-primary-badge);
	}

	.bottom-left-triangle {
		bottom: 0;
		left: 0;
		border-left-color: var(--clr-primary-badge);
		border-bottom-color: var(--clr-primary-badge);
	}

	.top-right-triangle {
		top: 0;
		right: 0;
		border-right-color: var(--clr-primary-badge);
		border-top-color: var(--clr-primary-badge);
	}

	.top-left-triangle {
		top: 0;
		left: 0;
		border-left-color: var(--clr-primary-badge);
		border-top-color: var(--clr-primary-badge);
	}
</style>
