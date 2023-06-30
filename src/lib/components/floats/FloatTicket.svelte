<script lang="ts">
	import { browser } from '$app/environment';
	import type { FLOAT } from '$lib/types/float/float.interface';

	export let float: FLOAT;
	export let showBack = false;
	export let minWidth = '300px';
	export let maxWidth = '600px';

	let flip: boolean = false;

	// When the FLOAT ticket is rendered in the Event Generator, we receive the image as a File, not a URL.
	// The reactive statement bellow, checks if the image is a File and then transforms it into a base 64 format.
	// Then, it displays the image as a background in the floatBack div.
	$: if (
		typeof float.eventImage !== 'string' &&
		float.eventImage?.type &&
		float.eventImage?.type.startsWith('image/') &&
		browser
	) {
		displayImage(float.eventImage as File, floatBack);
	}

	$: if (
		typeof float.eventLogo !== 'string' &&
		float.eventLogo?.type &&
		float.eventLogo?.type.startsWith('image/') &&
		browser
	) {
		displayImage(float.eventLogo as File, floatLogo);
	}

	let floatBack: HTMLDivElement;
	let floatLogo: HTMLDivElement;

	const displayImage = (file: File, element: HTMLDivElement) => {
		const reader = new FileReader();
		reader.readAsDataURL(file); // base 64 format

		reader.onload = () => {
			element.style.backgroundImage = `url('${reader.result}')`; /* asynchronous call. This function runs once reader is done reading file. reader.result is the base 64 format */
			element.style.backgroundSize = 'cover';
		};
	};
</script>

<div
	class="main-wrapper"
	style={`min-width: ${minWidth}; max-width: ${maxWidth}`}
	on:click={() => (flip = !flip)}
>
	<div
		class="secondary-wrapper"
		class:flip={flip || showBack}
		class:inverse-flip={showBack && flip}
	>
		<div class="float-front">
			<div class="content">
				<div class="header-wrapper">
					<span class="large">FLOAT</span>
					<span class="label">{`#${float.id}`}</span>
				</div>
				<div class="body-wrapper">
					<span><strong>{float.originalRecipient}</strong> has attended</span>
					<div class="logo-wrapper row-4">
						{#if float.eventLogo && typeof float.eventLogo === 'string'}
							<img src={float.eventLogo} alt="event-logo" />
						{:else if float.eventLogo && typeof float.eventLogo !== 'string'}
							<div class="float-logo" bind:this={floatLogo} />
						{/if}
						<div id="title-style" class="column-space-between">
							<h3 class="w-medium">{float.eventName}</h3>
							<span class="label">{float.eventType}</span>
						</div>
					</div>
					<span>Organized by <strong>{float.eventHost}</strong></span>
				</div>
				<div class="footer-wrapper">
					<span id="powered-by-style" class="small">Powered by the Flow Blockchain</span>
				</div>
			</div>
		</div>
		<div class="float-back" bind:this={floatBack} id="element-to-exclude">
			{#if float.eventImage && typeof float.eventImage === 'string'}
				<img src={float.eventImage} alt="float" />
			{:else if float.eventImage === undefined}
				<img src="/test-toucan.png" alt="float" />
			{/if}
		</div>
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		perspective: 1400px;
		width: 100%;
		container-type: inline-size;
		container-name: ticket;
		cursor: pointer;

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

			.float-front,
			.float-back {
				position: absolute;
				width: 100%;
				height: 100%;
				-webkit-backface-visibility: hidden; /* Safari */
				backface-visibility: hidden;
				top: 0;
				border-radius: 2em;
			}

			.float-front {
				background-color: var(--clr-surface-secondary);
				padding: 5% 7%;
				position: relative;
				width: 100%;
				height: 100%;
				transition: transform 1.4s;
				transform-style: preserve-3d;

				.content {
					border: 1px solid var(--clr-border-primary);
					border-radius: 1.3em;
					width: 100%;
					height: 100%;
					display: grid;
					grid-template-rows: auto 1fr auto;

					.header-wrapper,
					.footer-wrapper {
						display: flex;
						flex-direction: row;
						align-items: center;
					}

					.header-wrapper {
						padding: 3% 7%;
						justify-content: space-between;
					}

					.footer-wrapper {
						padding: 1.5% 7%;
						justify-content: flex-end;
					}

					.body-wrapper {
						padding: 3% 7%;
						display: flex;
						flex-direction: column;
						justify-content: space-between;
						gap: 0.8em;
						border-block: 1px dashed var(--clr-border-primary);

						h3 {
							font-size: 2.2em;
							margin-bottom: 0.15em;
						}

						.logo-wrapper {
							.float-logo,
							img {
								width: 80px;
								height: 80px;
								border-radius: var(--radius-1);
							}
						}
					}
				}
			}

			.float-back {
				transform: rotateY(180deg);
				overflow: hidden;
			}
		}
	}

	.flip {
		transform: rotateY(180deg);
	}

	.inverse-flip {
		transform: rotateY(0deg);
	}

	span {
		font-size: 1em;

		&.small {
			font-size: 0.8em;
		}

		&.large {
			font-size: 1.2em;
		}

		&.label {
			font-size: 0.8em;
			background-color: var(--clr-primary-badge);
			width: fit-content;
			padding: 0.4em 0.8em;
			border-radius: 0.7em;
			line-height: normal;
		}
	}
</style>
