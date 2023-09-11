<script lang="ts">
	import type { CertificateType } from '$lib/types/event/event-type.type';
	import type { MedalType } from '$lib/types/event/medal-types.type';
	import type { FloatColors } from '../float-colors.type';

	export let certificateType: CertificateType;
	export let color: FloatColors = 'neutral';
	export let level: MedalType | null;
</script>

<div class="main-wrapper">
	<!-- <img src="/ec-logo.png" alt="FLOAT logo" /> -->
	<span class="heading w-medium">FLOAT</span>
	{#if certificateType === 'medal' && level !== null}
		<span class={`${color}`}>{level}</span>
	{/if}
	<span class={`off ${color}`}>{certificateType}</span>
</div>

<style lang="scss">
	/* img {
		width: 1.4em;
		height: 1.4em;
		object-fit: cover;
	} */
	.main-wrapper {
		display: flex;
		align-items: baseline;
		flex-direction: row;
		gap: 0.2em;

		.heading {
			font-size: 1.08em;
			font-family: var(--font-heading);
			color: var(--clr-heading-main);
			letter-spacing: 0.04em;
			opacity: 0.8;
		}

		.off {
			color: var(--clr-text-off);
			opacity: 0.7;
			font-family: var(--font-text);
			font-size: 1em;
		}

		.gold {
			color: goldenrod;
		}

		.silver {
			color: rgb(120, 120, 120);
		}

		.bronze {
			color: rgb(205, 127, 50);
		}
	}
</style>
