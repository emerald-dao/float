<script lang="ts">
	import { EVENT_TYPE_DETAILS } from '$lib/types/event/event-type.type';
	import type { FLOAT } from '$lib/types/float/float.interface';

	export let float: FLOAT;
	export let showBack = false;
	export let minWidth = '300px';
	export let maxWidth = '600px';

	let flip: boolean = false;

	let isTicket: boolean;
	$: isTicket = EVENT_TYPE_DETAILS[float.eventType].certificateType === 'ticket';

	// When the FLOAT ticket is rendered in the Event Generator, we receive the image as a File, not a URL.
	// The reactive statement bellow, checks if the image is a File and then transforms it into a base 64 format.
	// Then, it displays the image as a background in the floatBack div.
	$: if (
		(typeof float.eventImage === 'string' ||
			(float.eventImage?.type && float.eventImage?.type.startsWith('image/'))) &&
		floatBack
	) {
		displayImage(float.eventImage, floatBack);
	}

	let floatBack: HTMLDivElement;

	const displayImage = (file: File | string, element: HTMLDivElement) => {
		if (typeof file === 'string') {
			element.style.backgroundImage = `url('${file}')`;
			element.style.backgroundSize = 'cover';
			element.style.backgroundPosition = 'center';
			element.style.backgroundColor = 'var(--clr-surface-secondary)';
		} else {
			const reader = new FileReader();
			reader.readAsDataURL(file); // base 64 format

			reader.onload = () => {
				element.style.backgroundImage = `url('${reader.result}')`; /* asynchronous call. This function runs once reader is done reading file. reader.result is the base 64 format */
				element.style.backgroundSize = 'cover';
				element.style.backgroundPosition = 'center';
				element.style.backgroundColor = 'var(--clr-surface-secondary)';
			};
		}
	};
</script>

<div
	class="main-wrapper"
	style={`min-width: ${minWidth}; max-width: ${maxWidth};`}
	on:click={() => (flip = !flip)}
>
	<div
		class="secondary-wrapper"
		class:flip={flip || showBack}
		class:inverse-flip={showBack && flip}
	>
		<slot />
		<div id="float-back" class="center" class:ticket={isTicket} bind:this={floatBack}>
			{#if float.eventImage === undefined}
				<div class="content">
					<p>Insert an image</p>
				</div>
			{/if}
		</div>
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
		filter: drop-shadow(var(--shadow-large-x) 5px 10px var(--shadow-large-color));

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

		.secondary-wrapper {
			position: relative;
			width: 100%;
			height: 100%;
			transition: transform 0.8s;
			transform-style: preserve-3d;
			aspect-ratio: 5 / 3;

			#float-back {
				transform: rotateY(180deg);
				overflow: hidden;
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
			}

			.ticket {
				background: radial-gradient(
						circle at left center,
						transparent 4%,
						var(--clr-surface-secondary) 4%,
						var(--clr-surface-secondary) 80%,
						transparent 0
					),
					radial-gradient(
						circle at right center,
						transparent 4%,
						var(--clr-surface-secondary) 4%,
						var(--clr-surface-secondary) 80%,
						transparent 0
					);
				mask-image: radial-gradient(
						circle at left center,
						transparent 4%,
						var(--clr-surface-secondary) 4%,
						var(--clr-surface-secondary) 80%,
						transparent 0
					),
					radial-gradient(
						circle at right center,
						transparent 4%,
						var(--clr-surface-secondary) 4%,
						var(--clr-surface-secondary) 80%,
						transparent 0
					);
			}
		}
	}

	.flip {
		transform: rotateY(180deg);
	}

	.inverse-flip {
		transform: rotateY(0deg);
	}
</style>
