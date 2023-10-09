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

<section>
	<div class="container-small">
		<h4>Pinned FLOATs</h4>
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
	</div>
</section>

<style lang="scss">
	section {
		position: relative;
		border-bottom: 1px dashed var(--clr-border-primary);
		width: calc(100vw - 1em);

		.container-small {
			display: flex;
			flex-direction: column;
			align-items: center;
			gap: var(--space-2);
			overflow: visible;

			.carousel-wrapper {
				width: 100%;

				.float-wrapper {
					padding: var(--space-8) var(--space-5);
				}
			}
		}
	}
</style>
