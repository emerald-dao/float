<script lang="ts">
	import { Button } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';

	export let id: string;
	export let qr: boolean = false;
	export let page: boolean = false;
	export let user: {};
</script>

<div class="main-wrapper">
	<div class="row-1">
		{#if page}
			<Icon icon="ph:app-window" color="var(--clr-neutral-600)" />
			<p>Claiming page</p>
		{:else if qr}
			<Icon icon="ic:baseline-qrcode" color="var(--clr-neutral-600)" />
			<p>QR Code</p>
		{/if}
	</div>
	<div class="row-3 link-wrapper">
		{#if page}
			<span class="link">https://floats.city/event/{user.name}/{id}</span>
		{:else if qr}
			<span class="link">https://floats.city/event/{user.name}/{id}/qr</span>
		{/if}
		<div class="row-2">
			<div class="button-wrapper">
				<Button type="transparent">
					<Icon icon="ph:copy-bold" hFlip={true} color="var(--clr-text-main)" />
				</Button>
			</div>
			<div class="button-wrapper">
				<Button type="transparent">
					<Icon icon="gridicons:external" color="var(--clr-text-main)" />
				</Button>
			</div>
			<div class="button-wrapper">
				<Button type="transparent">
					<Icon icon="tabler:share" color="var(--clr-text-main)" />
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
			width: 100%;

			p {
				color: var(--clr-text-off);
			}
		}

		.link-wrapper {
			display: grid;
			grid-template-columns: 3fr 1fr;
			width: 100%;

			.link {
				border: var(--border-width-primary) solid var(--clr-neutral-600);
				border-radius: var(--radius-2);
				padding: var(--space-2) var(--space-3);
			}

			.row-2 {
				align-items: center;
				justify-content: flex-end;

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
