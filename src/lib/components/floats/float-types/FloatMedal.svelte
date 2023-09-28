<script lang="ts">
	import type { MedalType } from '$lib/types/event/medal-types.type';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import type { FloatColors } from '../float-colors.type';
	import FloatMedalAndCertificateFront from './atoms/FloatMedalAndCertificateFront.svelte';

	export let float: FLOAT;
	export let isForScreenshot = false; // When true, the float will be rendered without some details (e.g. Recipient and Float Serial )
	export let hasBorder = false;

	let level = float.extraMetadata.medalType as MedalType;
	let color = level === 'participation' ? 'neutral' : (level as FloatColors);
</script>

<div class={`float-front ${color}`} class:dashed-border={hasBorder}>
	<FloatMedalAndCertificateFront {float} labelColor={color} {isForScreenshot} />
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
		padding: 5% 7%;
		width: 100%;
		height: 100%;

		&.dashed-border:before {
			position: absolute;
			content: '';
			display: block;
			bottom: 0;
			top: 0;
			right: 0;
			width: 0;
			border-left: 1px dashed var(--clr-border-primary);
		}

		&.neutral {
			background-color: var(--clr-surface-secondary);
		}

		&.gold {
			background: linear-gradient(
				150deg,
				rgb(253, 241, 204) 0%,
				rgb(255, 250, 232) 20%,
				rgb(255, 246, 221) 30%,
				rgb(255, 249, 227) 60%,
				rgb(255, 244, 217) 70%,
				rgb(255, 251, 234) 85%,
				rgb(255, 245, 216) 90%,
				rgb(255, 246, 217) 100%
			);
		}

		&.silver {
			background: linear-gradient(
				150deg,
				rgb(227, 227, 227) 0%,
				rgb(221, 221, 221) 10%,
				rgb(236, 236, 236) 25%,
				rgb(212, 212, 212) 50%,
				rgb(232, 232, 232) 70%,
				rgb(232, 232, 232) 85%,
				rgb(236, 236, 236) 90%,
				rgb(227, 227, 227) 100%
			);
		}

		&.bronze {
			background: linear-gradient(
				150deg,
				rgb(243, 226, 209) 0%,
				rgb(249, 218, 185) 20%,
				rgb(247, 221, 194) 30%,
				rgb(248, 232, 216) 60%,
				rgb(250, 231, 211) 70%,
				rgb(246, 221, 195) 85%,
				rgb(255, 228, 205) 90%,
				rgb(239, 232, 226) 100%
			);
		}
	}
</style>
