<script lang="ts">
	import { EVENT_TYPE_DETAILS } from '$lib/types/event/even-type.type';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import Icon from '@iconify/svelte';

	export let float: FLOAT;

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

<div class="main-wrapper">
	{#if float.eventLogo && typeof float.eventLogo === 'string'}
		<img src={float.eventLogo} alt="event-logo" />
	{:else if float.eventLogo && typeof float.eventLogo !== 'string'}
		<div class="float-logo" bind:this={floatLogo} />
	{:else}
		<div class="image-placeholder">
			<p>Insert an image</p>
		</div>
	{/if}
	<div class="column-space-between heading-wrapper">
		{#if float.eventName.length > 0}
			<h3 class="w-medium">{float.eventName}</h3>
		{:else}
			<h3 class="w-medium event-name-placeholder">Event Name</h3>
		{/if}
		{#if float.eventType}
			<div class="row align-center">
				<Icon icon="tabler:code" width="1.1em" color="var(--clr-text-off)" />
				<span class="event-type w-medium">{EVENT_TYPE_DETAILS[float.eventType].eventTypeName}</span>
			</div>
		{/if}
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		display: flex;
		flex-direction: row;
		align-items: center;
		justify-content: flex-start;
		gap: 0.7em;

		img {
			width: 100%;
			height: 100%;
			object-fit: cover;
			object-position: center;
			border-radius: 1.3em;
		}

		.float-logo,
		img,
		.image-placeholder {
			min-width: 18%;
			max-width: 18%;
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

		.heading-wrapper {
			overflow: hidden;

			h3 {
				font-size: 1.47em;
				text-overflow: ellipsis;
				white-space: nowrap;
				overflow: hidden;
				width: 100%;
				color: var(--clr-heading-main);
				line-height: 1.2em;
				margin-bottom: 0.25em;

				&.event-name-placeholder {
					color: var(--clr-text-off);
				}
			}

			.event-type {
				color: var(--clr-text-off);
				font-size: 0.9em;
				line-height: 1.1em;
				margin-left: 0.21em;
			}
		}
	}
</style>
