<script type="ts">
	import FloatTicket from '$lib/components/floats/FloatTicket.svelte';
	import { generatedNft } from '$lib/features/event-generator/stores/EventGeneratorData';
	import Icon from '@iconify/svelte';
	import ClaimTicket from './atoms/ClaimTicket.svelte';

	let claims = [
		{
			image:
				'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',
			walletAddress: '0x2f3043tpx3f43g',
			time: '17:32',
			date: '04/20/23'
		},
		{
			image:
				'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',
			walletAddress: '0x2f3043tpx3f43g',
			time: '17:32',
			date: '04/20/23'
		},
		{
			image:
				'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',
			walletAddress: '0x2f3043tpx3f43g',
			time: '17:32',
			date: '04/20/23'
		},
		{
			image:
				'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',
			walletAddress: '0x2f3043tpx3f43g',
			time: '17:32',
			date: '04/20/23'
		},
		{
			image:
				'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',
			walletAddress: '0x2f3043tpx3f43g',
			time: '17:32',
			date: '04/20/23'
		}
	];
</script>

<div class="main-wrapper">
	<div class="top-wrapper">
		<div class="column-wrapper">
			<div class="status-wrapper">
				<Icon icon="ion:ellipse-sharp" color="var(--clr-primary-main)" />
				<p class="xsmall">active</p>
			</div>
		</div>
		<div class="column-wrapper">
			<h5>2,305 / ∞</h5>
			<p class="small">FLOATs claimed</p>
		</div>
		<div class="column-wrapper">
			<p>20 days left</p>
		</div>
	</div>
	<div class="ticket-wrapper">
		<FloatTicket float={$generatedNft} />
	</div>
	<div class="claims-wrapper">
		<div class="row-1">
			<Icon icon="tabler:news" color="var(--clr-neutral-600)" />
			<p>LATEST CLAIMS</p>
		</div>
		{#each claims as claim}
			<ClaimTicket {claim} />
		{/each}
	</div>
</div>

<style type="scss">
	.main-wrapper {
		display: flex;
		flex-direction: column;
		justify-content: center;
		align-items: center;
		gap: var(--space-10);

		.top-wrapper {
			display: flex;
			justify-content: space-between;
			width: 100%;
			align-items: center;
			padding: var(--space-4) var(--space-4);
			border-bottom: var(--border-width-primary) dashed var(--clr-border-primary);

			@include mq(medium) {
				padding: var(--space-6) var(--space-12);
			}

			.status-wrapper {
				display: flex;
				width: fit-content;
				background-color: var(--clr-primary-badge);
				padding: var(--space-1) var(--space-2);
				border-radius: var(--radius-1);
				text-align: center;
				gap: var(--space-1);

				p {
					color: var(--clr-primary-main);
				}
			}

			.column-wrapper {
				display: flex;
				flex-direction: column;
				justify-content: center;
				align-items: center;

				h5 {
					margin: 0;
				}
			}
		}

		.ticket-wrapper {
			padding: 0 var(--space-3);
		}

		.claims-wrapper {
			display: flex;
			flex-direction: column;
			justify-content: center;
			width: 100%;
			justify-content: center;
			gap: var(--space-4);

			.row-1 {
				display: flex;
				align-items: center;
				justify-content: flex-start;
				padding: var(--space-2) var(--space-12);
				width: 100%;
				border-bottom: var(--border-width-primary) dashed var(--clr-border-primary);
			}
		}
	}
</style>
