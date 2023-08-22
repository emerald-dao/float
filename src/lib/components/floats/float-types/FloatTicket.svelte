<script lang="ts">
	import { EVENT_TYPE_DETAILS } from '$lib/types/event/even-type.type';
	import type { FLOAT } from '$lib/types/float/float.interface';
	import type { Profile } from '$lib/types/user/profile.interface';
	import getProfile from '$lib/utilities/profiles/getProfile';
	import { onMount } from 'svelte';

	export let float: FLOAT;

	let creatorProfile: Profile;

	onMount(async () => {
		creatorProfile = await getProfile(float.eventHost);
	});

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

<div class="float-front">
	<div class="content">
		<div class="header-wrapper">
			<span class="large">FLOAT</span>
			<span class="label">{`#${float.id}`}</span>
		</div>
		<div class="body-wrapper">
			<div class="logo-wrapper row-4">
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
						<span class="label">{EVENT_TYPE_DETAILS[float.eventType].eventTypeName}</span>
					{/if}
				</div>
			</div>
			<span
				>Organized by
				<span class="w-medium"
					>{creatorProfile && creatorProfile.type === 'find'
						? creatorProfile.name
						: float.eventHost}
				</span>
			</span>
		</div>
		<div class="footer-wrapper">
			<span class="small">Powered by the Flow Blockchain</span>
		</div>
	</div>
</div>

<style lang="scss">
	.float-front {
		position: absolute;
		width: 100%;
		height: 100%;
		-webkit-backface-visibility: hidden; /* Safari */
		backface-visibility: hidden;
		top: 0;
		border-radius: 2em;
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
				width: 100%;

				span {
					width: 100%;
					text-align: right;
				}
			}

			.body-wrapper {
				padding: 3% 7%;
				display: flex;
				flex-direction: column;
				justify-content: space-between;
				gap: 0.8em;
				border-block: 1px dashed var(--clr-border-primary);
				color: var(--clr-text-off);
				height: 100%;

				.w-medium {
					color: var(--clr-text-main);
				}

				.logo-wrapper {
					display: flex;
					flex-direction: row;
					align-items: center;
					justify-content: flex-start;

					.float-logo,
					img,
					.image-placeholder {
						min-width: 18%;
						max-width: 18%;
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
		}
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
