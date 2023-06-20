<script type="ts">
	import FloatTicket from '$lib/components/floats/FloatTicket.svelte';
	import type { FLOAT } from '$lib/types/float/float.interface';

	let float: FLOAT = {
		id: '1234',
		dateReceived: '6/14/2023',
		eventDescription: 'Event description 1',
		originalRecipient: 'John Doe',
		eventName: 'Emerald City',
		eventType: 'hackathon',
		eventHost: 'Emerald DAO',

		eventId: '1234',
		eventImage:
			'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',
		eventLogo:
			'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',

		serial: 'NO IDEA',
		totalSupply: '4536',
		transferrable: false
	};
</script>

<div class="main-wrapper">
	<div class="top-wrapper">
		<div>
			<h4>{`#${float.eventId}`}</h4>
			<p class="small">Event ID</p>
		</div>
		<div>
			<h4>{float.totalSupply}</h4>
			<p class="small">FLOATs claimed</p>
		</div>
	</div>
	<FloatTicket {float} />
	<div class="details-wrapper">
		<div>
			<p class="large">{float.dateReceived}</p>
			<p class="small">Start Date</p>
		</div>
		<div>
			<p class="large">{float.dateReceived}</p>
			<p class="small">End Date</p>
		</div>
		<div>
			<p class="large">Free</p>
			<p class="small">Price</p>
		</div>
	</div>
</div>

<style type="scss">
	.main-wrapper {
		display: flex;
		flex-direction: column;
		justify-content: center;
		align-items: center;
		gap: var(--space-8);
		padding: var(--space-6);

		.top-wrapper {
			display: grid;
			grid-template-columns: repeat(2, 1fr);
			text-align: center;
			width: 80%;

			h4 {
				color: var(--clr-text-main);
			}

			p {
				color: var(--clr-text-off);
			}
		}

		.details-wrapper {
			display: grid;
			grid-template-columns: repeat(3, 1fr);
			text-align: center;
			border-top: 1px dashed var(--clr-border-primary);
			border-bottom: 1px dashed var(--clr-border-primary);
			padding: var(--space-5) 0 var(--space-5) 0;
			width: 80%;

			.small {
				color: var(--clr-text-off);
			}
		}
	}
</style>
