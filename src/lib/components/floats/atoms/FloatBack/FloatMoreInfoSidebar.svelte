<script lang="ts">
	import { page } from '$app/stores';
	import generateQRCode from '$lib/utilities/generateQRCode';
	import Icon from '@iconify/svelte';
	import { onMount } from 'svelte';
	import { fly } from 'svelte/transition';
	import type { FLOAT } from '$lib/types/float/float.interface';

	export let float: FLOAT;

	let show = false;

	let qrCodeDataUrl: string;

	onMount(async () => {
		let qr = `${$page.url.origin}/event/${$page.params.username}/${float.eventId}`;
		qrCodeDataUrl = await generateQRCode(qr);
	});
</script>

{#if show}
	<div
		class="main-wrapper"
		in:fly={{ x: 500, opacity: 1, duration: 1000 }}
		out:fly={{ x: 500, opacity: 1, duration: 2000 }}
		on:click|stopPropagation={() => (show = !show)}
	>
		<div class="close-button-wrapper">
			<button class="close-button" on:click|stopPropagation={() => (show = !show)}>
				<div class="button-content">
					<div class="icon-wrapper rotate-180">
						<Icon icon="tabler:chevron-left" />
					</div>
				</div>
			</button>
		</div>
		<div class="content-wrapper">
			<div class="top-content-wrapper">
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
	</div>
{/if}
<button class="open-button" on:click|stopPropagation={() => (show = !show)}>
	<div class="button-content">
		<div class="icon-wrapper">
			<Icon icon="tabler:chevron-left" />
		</div>
	</div>
</button>

<style lang="scss">
	.main-wrapper {
		width: 100%;
		height: 100%;
		position: absolute;
		right: 0;
		width: fit-content;
		max-width: 40%;
		z-index: 2;
		display: flex;
		flex-direction: row;

		.close-button-wrapper {
			height: 100%;
			width: fit-content;
			display: flex;
			flex-direction: row;
			align-items: flex-start;
			position: relative;
		}

		.content-wrapper {
			display: flex;
			flex-direction: column;
			justify-content: space-between;
			background-color: var(--clr-surface-secondary);
			width: 100%;
			height: 100%;
			padding: 18% 10% 18% 12%;
			border-left: 1px solid var(--clr-border-primary);

			.top-content-wrapper {
				display: flex;
				flex-direction: column;
				gap: 4%;
				height: 100%;
				width: fit-content;
			}
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

	.open-button,
	.close-button {
		position: absolute;
		right: 0;
		top: 18%;
		padding: 10px 0px 10px 10px;
		cursor: pointer;
		border: none;
		background-color: transparent;

		.button-content {
			background-color: var(--clr-surface-secondary);
			color: var(--clr-text-main);
			padding: 0.5em 0.1em 0.5em 0.1em;
			border-bottom-left-radius: 0.7em;
			border-top-left-radius: 0.7em;
			display: flex;
			align-items: center;
			border-style: solid;
			border-color: var(--clr-border-primary);
			border-width: 1px 0px 1px 1px;

			.icon-wrapper {
				display: flex;
				align-items: center;
				justify-content: center;
				transition: 0.4s;
			}
		}
	}

	.close-button {
		right: -1px;
		z-index: 5;

		.button-content {
			.icon-wrapper {
				&.rotate-180 {
					transform: rotate(180deg);
				}
			}
		}
	}
</style>
