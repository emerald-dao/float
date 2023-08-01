<script lang="ts">
	import { page } from '$app/stores';
	import { Button } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';
	import { writable } from 'svelte/store';

	export let id: string;
	export let qr: boolean = false;
	export let eventPage: boolean = false;
	export let user: {};

	const tooltipText = writable('Copy to clipboard');

	function copyToClipboard() {
		// Determine which URL to copy based on the `{#if}` conditions
		const urlToCopy = eventPage
			? `${$page.url.origin}/event/${user.name}/${id}`
			: `${$page.url.origin}/event/${user.name}/${id}/qr`;

		const tempInput = document.createElement('textarea');
		tempInput.value = urlToCopy;
		document.body.appendChild(tempInput);

		tempInput.select();
		tempInput.setSelectionRange(0, 99999);

		document.execCommand('copy');

		document.body.removeChild(tempInput);

		tooltipText.set('Copied');

		setTimeout(() => {
			tooltipText.set('Copy to clipboard');
		}, 2000);
	}
</script>

<div class="main-wrapper">
	<div class="row-1">
		{#if eventPage}
			<Icon icon="ph:app-window" color="var(--clr-neutral-600)" />
			<p>Claiming page</p>
		{:else if qr}
			<Icon icon="ic:baseline-qrcode" color="var(--clr-neutral-600)" />
			<p>QR Code</p>
		{/if}
	</div>
	<div class="row-3 link-wrapper">
		{#if eventPage}
			<span class="link">{$page.url.origin}/event/{user.name}/{id}</span>
		{:else if qr}
			<span class="link">{$page.url.origin}/event/{user.name}/{id}/qr</span>
		{/if}
		<div class="row-3">
			<div class="button-wrapper" data-tooltip={$tooltipText}>
				<Button type="transparent" on:click={copyToClipboard}>
					<Icon icon="tabler:copy" color="var(--clr-text-main)" />
				</Button>
			</div>
			<div class="button-wrapper" data-tooltip="Open in new tab">
				<Button
					type="transparent"
					target="_blank"
					href={eventPage
						? `${$page.url.origin}/event/${user.name}/${id}`
						: `${$page.url.origin}/event/${user.name}/${id}/qr`}
				>
					<Icon icon="tabler:external-link" color="var(--clr-text-main)" />
				</Button>
			</div>
		</div>
	</div>
</div>

<style lang="scss">
	.main-wrapper {
		display: flex;
		flex-direction: column;
		gap: var(--space-2);
		border: var(--border-width-primary) dashed var(--clr-neutral-600);
		padding: var(--space-2) var(--space-3);
		border-radius: var(--radius-2);

		.row-1 {
			align-items: center;
		}

		.link-wrapper {
			display: flex;
			flex-direction: column;

			@include mq(small) {
				display: grid;
				grid-template-columns: 3fr 1fr;
			}

			.link {
				border: var(--border-width-primary) solid var(--clr-neutral-600);
				border-radius: var(--radius-2);
				padding: var(--space-2) var(--space-3);
				overflow: hidden;
			}

			.row-3 {
				align-items: center;

				@include mq(small) {
					justify-content: center;
				}

				.button-wrapper {
					display: flex;
					align-items: center;
					justify-content: center;
					border-radius: var(--radius-1);
					border: var(--border-width-primary) solid var(--clr-neutral-600);
				}
			}
		}
	}
</style>
