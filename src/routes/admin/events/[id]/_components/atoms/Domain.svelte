<script type="ts">
	import { Button } from '@emerald-dao/component-library';
	import Icon from '@iconify/svelte';

	export let claimableLinks: Link[];

	type Link = {
		type: string;
		link: string;
	};
</script>

<div class="domains-wrapper">
	<div class="row-1">
		<Icon icon="ph:link" color="var(--clr-neutral-600)" />
		<p>DOMAINS</p>
	</div>
	{#each claimableLinks as data}
		<div class="main-wrapper">
			<div class="row-1">
				{#if data.type === 'Page'}
					<Icon icon="ph:app-window" color="var(--clr-neutral-600)" />
					<p>Claiming page</p>
				{:else}
					<Icon icon="ic:baseline-qrcode" color="var(--clr-neutral-600)" />
					<p>QR Code</p>
				{/if}
			</div>
			<div class="row-3 input-wrapper">
				<input type="text" placeholder={data.link} />
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
	{/each}
</div>

<style type="scss">
	.domains-wrapper {
		display: flex;
		flex-direction: column;
		gap: var(--space-3);

		.row-1 {
			align-items: center;
			p {
				color: var(--clr-text-off);
			}
		}
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

			.input-wrapper {
				display: grid;
				grid-template-columns: 3fr 1fr;
				width: 100%;

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
	}
</style>
