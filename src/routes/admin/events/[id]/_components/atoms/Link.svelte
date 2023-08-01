<script lang="ts">
	import { Button, CopyToClipboard } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';
	import { writable } from 'svelte/store';

	export let id: string;
	export let qr: boolean = false;
	export let page: boolean = false;
	export let user: {};

	const tooltipText = writable('Copy to clipboard');

	function copyToClipboard() {
		// Determine which URL to copy based on the `{#if}` conditions
		const urlToCopy = page
			? `https://floats.city/event/${user.name}/${id}`
			: `https://floats.city/event/${user.name}/${id}/qr`;

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
		{#if page}
			<p class="small row-1 align-center">
				<Icon icon="tabler:browser" />
				Claiming page
			</p>
		{:else if qr}
			<p class="small row-1 align-center">
				<Icon icon="tabler:qrcode" />
				QR Code
			</p>
		{/if}
	</div>
	<div class="row-3 link-wrapper">
		{#if page}
			<span class="link">https://floats.city/event/{user.name}/{id}</span>
		{:else if qr}
			<span class="link">https://floats.city/event/{user.name}/{id}/qr</span>
		{/if}
		<div class="row-2">
			<div class="button-wrapper" data-tooltip={$tooltipText}>
				<Button type="transparent" on:click={copyToClipboard}>
					<Icon icon="tabler:copy" color="var(--clr-text-main)" />
				</Button>
			</div>
			<div class="button-wrapper" data-tooltip="Open in new tab">
				<Button
					type="transparent"
					target="_blank"
					href={page
						? `https://floats.city/event/${user.name}/${id}`
						: `https://floats.city/event/${user.name}/${id}/qr`}
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
				font-size: var(--font-size-1);
				width: 100%;
			}

			.row-2 {
				@include mq(small) {
					justify-content: flex-end;
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
