<script lang="ts">
	import { user } from '$lib/stores/flow/FlowStore';
	import { page } from '$app/stores';
	import { Button } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';
	import { writable } from 'svelte/store';

	export let id: string;
	export let linkType: 'qr' | 'eventPage';

	const tooltipText = writable('Copy to clipboard');

	function copyToClipboard() {
		// Determine which URL to copy based on the `{#if}` conditions
		const urlToCopy =
			linkType === 'eventPage'
				? `${$page.url.origin}/event/${$user.addr}/${id}`
				: `${$page.url.origin}/event/${$user.addr}/${id}/qr`;

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
		{#if linkType === 'eventPage'}
			<p class="small row-1 align-center">
				<Icon icon="tabler:browser" />
				Claiming page
			</p>
		{:else if linkType === 'qr'}
			<p class="small row-1 align-center">
				<Icon icon="tabler:qrcode" />
				QR Code
			</p>
		{/if}
	</div>
	<div class="row-3 link-wrapper">
		{#if linkType === 'eventPage'}
			<input
				class="link"
				type="text"
				disabled={true}
				placeholder={`${$page.url.origin}/event/${$user.addr}/${id}`}
			/>
		{:else if linkType === 'qr'}
			<input
				class="link"
				type="text"
				disabled={true}
				placeholder={`${$page.url.origin}/event/${$user.addr}/${id}/qr`}
			/>
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
					href={linkType === 'eventPage'
						? `${$page.url.origin}/event/${$user.addr}/${id}`
						: `${$page.url.origin}/event/${$user.addr}/${id}/qr`}
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
		border: var(--border-width-primary) dashed var(--clr-border-primary);
		padding: var(--space-3);
		border-radius: var(--radius-1);

		.row-1 {
			align-items: center;
		}

		.link-wrapper {
			display: flex;
			flex-direction: column;

			@include mq(small) {
				display: flex;
				flex-direction: row;
			}

			.link {
				border: var(--border-width-primary) solid var(--clr-border-primary);
				border-radius: var(--radius-1);
				padding: var(--space-1) var(--space-3);
				overflow: hidden;
				font-size: var(--font-size-0);
				color: var(--clr-text-main);
			}

			.row-3 {
				@include mq(small) {
					justify-content: center;
				}

				.button-wrapper {
					display: flex;
					align-items: center;
					justify-content: center;
					border-radius: var(--radius-1);
					border: var(--border-width-primary) solid var(--clr-border-primary);
				}
			}
		}
	}
</style>
