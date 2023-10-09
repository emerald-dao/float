<script lang="ts">
	import { browser } from '$app/environment';
	import Blur from '$lib/components/Blur.svelte';
	import Float from '$lib/components/floats/Float.svelte';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import Carousel from 'svelte-carousel';

	export let pinnedFloats: FLOAT[];

	let arrows: boolean;
	let autoplay: boolean;

	if (pinnedFloats.length > 1) {
		arrows = true;
		autoplay = true;
	} else {
		arrows = false;
		autoplay = false;
	}
</script>

<section class="pinned-float-section-wrapper">
	<div class="column align-center">
		<h4>Pinned FLOATs</h4>
	</div>
	<Blur color="tertiary" right="22%" top="15%" />
	<Blur left="22%" bottom="20%" />
	<div class="carousel-wrapper">
		{#if browser}
			<Carousel {autoplay} autoplayDuration={5000} duration={800} {arrows}>
				{#each pinnedFloats as float}
					<div class="float-wrapper column align-center">
						<Float {float} />
					</div>
				{/each}
			</Carousel>
		{/if}
	</div>
</section>

<style lang="scss">
	.pinned-float-section-wrapper {
		position: relative;
		display: flex;
		flex-direction: column;
		gap: var(--space-10);
		align-items: center;
		border-bottom: 1px dashed var(--clr-border-primary);
		overflow: hidden;

		.carousel-wrapper {
			width: 100%;
			padding: var(--space-12) var(--space-14);
			overflow: hidden;

			.float-wrapper {
				padding: var(--space-8);
			}
		}
	}
</style>
