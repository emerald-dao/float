<script lang="ts">
	import { browser } from '$app/environment';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import { Label } from '@emerald-dao/component-library';

	export let float: FLOAT;
	export let showBack = false;

	let hover: boolean = false;

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
	on:mouseenter={() => (hover = true)}
	on:mouseleave={() => (hover = false)}
	class="main-wrapper"
>
	<div
		class="secondary-wrapper"
		class:flip={hover || showBack}
		class:inverse-flip={showBack && hover}
	>
		<div class="float-front">
			<div class="content">
				<div class="header-wrapper">
					<span class="large">FLOAT</span>
					<Label color="tertiary">{`#${float.id}`}</Label>
				</div>
				<div class="body-wrapper">
					<span><strong>{float.originalRecipient}</strong> has attended</span>
					<div class="logo-wrapper row-4">
						{#if float.eventLogo && typeof float.eventLogo === 'string'}
							<img src={float.eventLogo} alt="event-logo" />
						{:else if float.eventLogo && typeof float.eventLogo !== 'string'}
							<div class="float-logo" bind:this={floatLogo} />
						{/if}
						<div class="column-space-between">
							<h3>{float.eventName}</h3>
							<Label color="neutral">{float.eventType}</Label>
						</div>
					</div>
					<span>Organized by <strong>{float.eventHost}</strong></span>
				</div>
				<div class="footer-wrapper">
					<span class="small">Powered by the Flow Blockchain</span>
				</div>
			</div>
		</div>
		<div class="float-back" bind:this={floatBack}>
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
		border-radius: var(--radius-5);
		width: 600px;
		perspective: 1400px;

		.secondary-wrapper {
			position: relative;
			width: 100%;
			height: 100%;
			transition: transform 0.8s;
			transform-style: preserve-3d;

			.float-front,
			.float-back {
				position: absolute;
				width: 100%;
				height: 100%;
				-webkit-backface-visibility: hidden; /* Safari */
				backface-visibility: hidden;
				top: 0;
				border-radius: var(--radius-5);
			}

			.float-front {
				background-color: var(--clr-surface-secondary);
				padding: var(--space-6) var(--space-12);
				position: relative;
				width: 100%;
				height: 100%;
				transition: transform 1.4s;
				transform-style: preserve-3d;

				.content {
					border: 1px solid var(--clr-border-primary);
					border-radius: var(--radius-4);
					.header-wrapper,
					.footer-wrapper {
						display: flex;
						flex-direction: row;
						align-items: center;
					}

					.header-wrapper {
						padding: var(--space-3) var(--space-10);
						justify-content: space-between;
					}

					.footer-wrapper {
						padding: var(--space-2) var(--space-10);
						justify-content: flex-end;
					}

					.body-wrapper {
						padding: var(--space-5) var(--space-10);
						display: flex;
						flex-direction: column;
						gap: var(--space-6);
						border-block: 1px dashed var(--clr-border-primary);

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
</style>
