<script lang="ts">
	import { EVENT_TYPE_DETAILS } from '$lib/types/event/event-type.type';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import FloatBack from '../atoms/FloatBack/FloatBack.svelte';

	export let float: FLOAT;
	export let showBack = false;
	export let minWidth = '300px';
	export let maxWidth = '600px';
	export let hasShadow = true;

	let flip: boolean = false;

	let isTicket = EVENT_TYPE_DETAILS[float.eventType].certificateType === 'ticket';
</script>

<div
	class="main-wrapper"
	class:shadow={hasShadow}
	style={`min-width: ${minWidth}; max-width: ${maxWidth};`}
	on:click={() => (flip = !flip)}
>
	<div
		class="secondary-wrapper"
		class:flip={flip || showBack}
		class:inverse-flip={showBack && flip}
	>
		<slot />
		<FloatBack {float} {isTicket} />
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		perspective: 1400px;
		width: 100%;
		aspect-ratio: 5 / 3;
		container-type: inline-size;
		container-name: ticket;
		cursor: pointer;

		&.shadow {
			filter: drop-shadow(var(--shadow-large-x) 5px 10px var(--shadow-large-color));
		}

		@container ticket (max-width: 500px) {
			.secondary-wrapper {
				font-size: 0.8rem;
				aspect-ratio: unset !important;
			}
		}

		@container ticket (max-width: 400px) {
			.secondary-wrapper {
				font-size: 0.7rem;
			}
		}

		@container ticket (max-width: 300px) {
			.secondary-wrapper {
				font-size: 0.5rem;
			}
		}

		.secondary-wrapper {
			position: relative;
			width: 100%;
			height: 100%;
			transition: transform 0.8s;
			transform-style: preserve-3d;
			aspect-ratio: 5 / 3;
		}
	}

	.flip {
		transform: rotateY(180deg);
	}

	.inverse-flip {
		transform: rotateY(0deg);
	}
</style>
