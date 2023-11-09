<script lang="ts">
	import type { FLOAT } from '$lib/types/float/float.interface';
	import FloatMoreInfoSidebar from './FloatMoreInfoSidebar.svelte';

	export let float: FLOAT;
	export let isTicket = false;

	let backgroundImage: HTMLDivElement;

	// When the FLOAT ticket is rendered in the Event Generator, we receive the image as a File, not a URL.
	// The reactive statement bellow, checks if the image is a File and then transforms it into a base 64 format.
	// Then, it displays the image as a background in the backgroundImage div.
	$: if (
		typeof float.backImage !== 'string' &&
		float.backImage?.type &&
		float.backImage?.type.startsWith('image/') &&
		backgroundImage
	) {
		displayImage(float.backImage, backgroundImage);
	}

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
				element.style.backgroundImage = `url('${reader.result}'), url('/ec-back-image.jpeg')`; /* asynchronous call. This function runs once reader is done reading file. reader.result is the base 64 format */
			};
		}
	};

	function handleImgError(e) {
		e.target.src = '/float-logo.png';
	}
</script>

<div id="float-back" class="center" class:ticket={isTicket}>
	{#if float.backImage && typeof float.backImage === 'string'}
		<div
			style={`background-image: url(${float.backImage}), url('/ec-back-image.jpeg')`}
			class="background-image"
		/>
	{:else if float.backImage && typeof float.backImage !== 'string'}
		<div bind:this={backgroundImage} class="background-image" />
	{:else if float.eventImage && typeof float.eventImage === 'string'}
		<div
			style={`background-image: url(${float.eventImage}), url('/ec-back-image.jpeg')`}
			class="background-image"
		/>
	{:else}
		<div class="content">
			<p class="medium">Insert an image</p>
			<span class="xsmall">Recommended size: 1920x1080</span>
		</div>
	{/if}
	<FloatMoreInfoSidebar {float} />
</div>

<style lang="scss">
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
		width: 100%;
		height: 100%;
		display: flex;
		flex-direction: row;
	}

	.background-image {
		width: 100%;
		height: 100%;
		background-size: cover;
		background-position: center;
		background-color: var(--clr-surface-secondary);
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

	.content {
		display: flex;
		flex-direction: column;
		align-items: center;
		gap: var(--space-1);

		span {
			font-style: italic;
		}
	}
</style>
