<script lang="ts">
	import type { FLOAT } from '$lib/types/float/float.interface';

	export let float: FLOAT;
	export let width = '18%';

	$: if (
		typeof float.eventImage !== 'string' &&
		float.eventImage?.type &&
		float.eventImage?.type.startsWith('image/') &&
		floatLogo
	) {
		displayImage(float.eventImage as File, floatLogo);
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
				element.style.backgroundImage = `url('${reader.result}'), url('/float-logo.png')`; /* asynchronous call. This function runs once reader is done reading file. reader.result is the base 64 format */
				element.style.backgroundSize = 'cover';
				element.style.backgroundPosition = 'center';
				element.style.backgroundColor = 'var(--clr-surface-secondary)';
			};
		}
	};

	function handleImgError(e) {
		e.target.src = '/float-logo.png';
	}
</script>

{#if float.eventImage && typeof float.eventImage === 'string'}
	<img
		src={float.eventImage}
		on:error={(e) => handleImgError(e)}
		alt="event-logo"
		style={`width: ${width}`}
	/>
{:else if float.eventImage && typeof float.eventImage !== 'string'}
	<div class="float-logo" bind:this={floatLogo} style={`width: ${width}`} />
{:else}
	<div class="image-placeholder" style={`width: ${width}`}>
		<p>Logo</p>
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
		// max-width: 15.5%;
		aspect-ratio: 1 / 1;
		border-radius: 0.3em;
		height: 100%;
	}

	.image-placeholder {
		border: 1px dashed var(--clr-border-primary);
		display: flex;
		justify-content: center;
		align-items: center;
		min-width: fit-content;
		padding: 0.2em;

		p {
			font-size: 0.5em;
			line-height: 1.1;
			text-align: center;
			color: var(--clr-text-off);
		}
	}
</style>
