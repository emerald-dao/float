<script lang="ts">
	import { EVENT_TYPE_DETAILS } from '$lib/types/event/even-type.type';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import { profile } from '$stores/flow/FlowStore';

	export let float: FLOAT;
	export let showBack = false;
	export let minWidth = '300px';
	export let maxWidth = '600px';
	export let isForScreenshot: boolean = false;

	let flip: boolean = false;

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

	let floatBack: HTMLDivElement;
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
					<!-- <span><span class="w-medium">{"float.originalRecipient"}</span> has attended</span> -->
					<div class="logo-wrapper">
						<div class="img-container row-4">
							{#if float.eventLogo && typeof float.eventLogo === 'string'}
								<img src={float.eventLogo} alt="event-logo" />
							{:else if float.eventLogo && typeof float.eventLogo !== 'string'}
								<div class="float-logo" bind:this={floatLogo} />
							{:else}
								<div class="image-placeholder">
									<p>Insert an image</p>
								</div>
							{/if}
							{#if float.eventName.length > 0}
								<h3 class="w-medium">{float.eventName}</h3>
							{:else}
								<h3 class="w-medium event-name-placeholder">Event Name</h3>
							{/if}
						</div>
						<div
							id={isForScreenshot ? 'title-style' : ''}
							class="column-space-between heading-wrapper"
						>
							{#if float.eventType}
								<span class="label">{EVENT_TYPE_DETAILS[float.eventType].eventTypeName}</span>
							{/if}
						</div>
					</div>
					{#if $profile?.name}
						<span class="w-medium profile-name-placeholder">{$profile?.name}</span>
					{/if}
					<span class="organized-by-placeholder"
						>Organized by <span class="w-medium">{float.eventHost}</span></span
					>
				</div>
				<div class="footer-wrapper">
					<span id={isForScreenshot ? 'powered-by-style' : ''} class="small"
						>Powered by the Flow Blockchain</span
					>
				</div>
			</div>
		</div>
		<div
			class="float-back center"
			bind:this={floatBack}
			id={isForScreenshot ? 'element-to-exclude' : ''}
		>
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

			.float-front,
			.float-back {
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

				img {
					width: 100%;
					height: 100%;
					object-fit: cover;
					object-position: center;
					border-radius: 1.3em;
				}

				.content {
					border: 1px dashed var(--clr-border-primary);
					border-radius: 1.3em;
					width: 100%;
					height: 100%;
					display: flex;
					align-items: center;
					justify-content: center;
					overflow: hidden;

					p {
						color: var(--clr-text-off);
					}
				}
			}

			.float-front {
				position: relative;
				transition: transform 1.4s;
				transform-style: preserve-3d;

				.content {
					border-style: solid;
					display: grid;
					grid-template-rows: auto 1fr auto;
					grid-template-columns: 100%;

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
						justify-content: space-around;
						gap: 0.8em;
						border-block: 1px dashed var(--clr-border-primary);
						color: var(--clr-text-off);
						height: 100%;

						.w-medium {
							color: var(--clr-text-main);
						}

						.logo-wrapper {
							display: flex;
							flex-direction: column;
							align-items: center;
							justify-content: center;

							.img-container {
								align-items: center;
								justify-content: center;
								width: 100%;

								.float-logo,
								img,
								.image-placeholder {
									max-width: 10%;
									min-width: 10%;
									height: auto;
									aspect-ratio: 1 / 1;
									border-radius: var(--radius-1);
								}

								.image-placeholder {
									border: 1px dashed var(--clr-border-primary);
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
									align-items: center;

									h3 {
										font-size: 1.5em;
										margin-bottom: 0.15em;
										text-overflow: ellipsis;
										white-space: nowrap;
										overflow: hidden;
										width: 100%;
										min-height: 1.2em;
										color: var(--clr-heading-main);

										&.event-name-placeholder {
											color: var(--clr-text-off);
										}
									}
								}
							}
						}
						.profile-name-placeholder {
							text-align: center;
							color: var(--clr-heading-main);
							font-size: var(--font-size-5);
						}
						.organized-by-placeholder {
							text-align: center;
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
