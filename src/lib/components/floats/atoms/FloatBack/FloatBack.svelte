<script lang="ts">
	import { fly } from 'svelte/transition';
	import { page } from '$app/stores';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import generateQRCode from '$lib/utilities/generateQRCode';
	import Icon from '@iconify/svelte';
	import { onMount } from 'svelte';

	export let float: FLOAT;
	export let isTicket = false;

	let backgroundImage: HTMLDivElement;
	let showDetails = false;

	// When the FLOAT ticket is rendered in the Event Generator, we receive the image as a File, not a URL.
	// The reactive statement bellow, checks if the image is a File and then transforms it into a base 64 format.
	// Then, it displays the image as a background in the backgroundImage div.
	$: if (
		(typeof float.eventImage === 'string' ||
			(float.eventImage?.type && float.eventImage?.type.startsWith('image/'))) &&
		backgroundImage
	) {
		displayImage(float.eventImage, backgroundImage);
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
				element.style.backgroundImage = `url('${reader.result}')`; /* asynchronous call. This function runs once reader is done reading file. reader.result is the base 64 format */
				element.style.backgroundSize = 'cover';
				element.style.backgroundPosition = 'center';
				element.style.backgroundColor = 'var(--clr-surface-secondary)';
			};
		}
	};

	let qrCodeDataUrl: string;

	onMount(async () => {
		let qr = `${$page.url.origin}/event/${$page.params.username}/${float.eventId}`;
		qrCodeDataUrl = await generateQRCode(qr);
	});
</script>

<div id="float-back" class="center" class:ticket={isTicket}>
	{#if float.eventImage}
		<div bind:this={backgroundImage} class="background-image" />
	{/if}
	{#if float.eventImage === undefined}
		<div class="content">
			<p>Insert an image</p>
		</div>
	{/if}
	{#if showDetails}
		<div class="b" transition:fly={{ x: 500, opacity: 1, duration: 1400 }}>
			<div class="a">
				<div class="column">
					<span class="w-medium"
						><Icon icon="tabler:box" color="var(--clr-primary-main)" />BLOCK
					</span>
					<p class="w-medium">#239325</p>
				</div>
				<div class="column">
					<span class="w-medium"
						><Icon icon="tabler:transfer" color="var(--clr-primary-main)" />TRANSACTION</span
					>
					<p class="w-medium">#239325</p>
				</div>
				<div class="column">
					<span class="w-medium"
						><Icon icon="tabler:calendar-event" color="var(--clr-primary-main)" />DATE</span
					>
					<p class="w-medium">12/12/2021</p>
				</div>
			</div>
			<div class="column">
				<span class="w-medium">EVENT PAGE</span>
				<img src={qrCodeDataUrl} alt="Event QR" />
			</div>
		</div>
	{/if}
	<button on:click|stopPropagation={() => (showDetails = !showDetails)}>
		<div class="icon-wrapper" class:rotate-180={showDetails}>
			<Icon icon="tabler:chevron-left" />
		</div>
	</button>
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
		// display: grid;
		// grid-template-columns: 5fr 2fr;
		display: flex;
		flex-direction: row;
	}

	.background-image {
		width: 100%;
		height: 100%;
	}

	.b {
		display: flex;
		flex-direction: column;
		justify-content: space-between;
		background-color: var(--clr-surface-secondary);
		width: 100%;
		height: 100%;
		padding: 6% 10% 6% 4%;
		position: absolute;
		right: 0;
		width: fit-content;
		max-width: 40%;

		.a {
			display: flex;
			flex-direction: column;
			gap: 4%;
			height: 100%;
			width: fit-content;
		}

		span {
			font-size: 0.65em;
			line-height: 1.4em;
			color: var(--clr-text-off);
			display: flex;
			flex-direction: row;
			gap: 0.2em;
			align-items: center;
			opacity: 0.7;
			letter-spacing: 0.04em;
			width: fit-content;
		}

		p {
			font-size: 0.8em;
			width: fit-content;
		}

		img {
			margin-top: 0.3em;
			width: 40%;
		}
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

	button {
		position: absolute;
		right: 0;
		background-color: var(--clr-surface-primary);
		border: none;
		color: var(--clr-primary-main);
		padding: 0.6em 1.7em 0.6em 0.4em;
		border-bottom-left-radius: 0.7em;
		border-top-left-radius: 0.7em;
		display: flex;
		align-items: center;
		border: 1px solid var(--clr-primary-main);

		.icon-wrapper {
			display: flex;
			align-items: center;
			justify-content: center;
			transition: 0.4s;

			&.rotate-180 {
				transform: rotate(180deg);
			}
		}
	}
</style>
