<script lang="ts">
	import type { FLOAT } from '$lib/types/float/float.interface';

	export let float: FLOAT;
	export let width = '18%';

	$: if (
		typeof float.eventLogo !== 'string' &&
		float.eventLogo?.type &&
		float.eventLogo?.type.startsWith('image/') &&
		floatLogo
	) {
		displayImage(float.eventLogo as File, floatLogo);
	}

	// Old FLOATs don't have an eventLogo property, they just have the eventImage property.
	// In this cases, we are going to use the eventImage as the eventLogo.
	$: if (typeof float.eventImage === 'string' && !float.eventLogo) {
		float.eventLogo = float.eventImage;
	}

	let floatLogo: HTMLDivElement;

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

{#if float.eventLogo && typeof float.eventLogo === 'string'}
	<img src={float.eventLogo} alt="event-logo" style={`width: ${width}`} />
{:else if float.eventLogo && typeof float.eventLogo !== 'string'}
	<div class="float-logo" bind:this={floatLogo} style={`width: ${width}`} />
{:else}
	<div class="image-placeholder" style={`width: ${width}`}>
		<p>Insert an image</p>
	</div>
{/if}

<style lang="scss">
	img {
		object-fit: cover;
		object-position: center;
		border-radius: 1.3em;
	}

	.float-logo,
	img,
	.image-placeholder {
		max-width: 15.5%;
		// max-width: 18%;
		aspect-ratio: 1 / 1;
		border-radius: var(--radius-1);
	}

	.image-placeholder {
		border: 0.5px dashed var(--clr-border-primary);
		display: flex;
		justify-content: center;
		align-items: center;
		padding: 1em;

		p {
			font-size: 0.6em;
			line-height: 1.1;
			text-align: center;
			color: var(--clr-text-off);
		}
	}
</style>
