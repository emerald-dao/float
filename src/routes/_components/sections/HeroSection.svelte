<script>
	import Blur from '$lib/components/Blur.svelte';
	import FloatTicket from '$lib/components/floats/FloatTicket.svelte';
	import { Button } from '@emerald-dao/component-library';
</script>

<section class="container-small center column-12">
	<Blur color="tertiary" right="0" top="30%" />
	<Blur left="0" bottom="20%" />
	<div class="column-1 center">
		<h1 class="w-bold">Reward Attendance</h1>
		<p class="h5">
			Create a unique and valuable experience for event attendees, while increasing engagement and
			trust for event creators.
		</p>
	</div>
	<FloatTicket
		float={{
			id: '123456789',
			originalRecipient: '0x99dd9933jj99k0',
			eventName: 'Emerald City',
			eventType: 'hackathon',
			eventHost: 'Emerald DAO',
			dateReceived: '1649886952.00000000',
			eventDescription: 'Hackathon dictated by Emerald City',
			eventId: '941533131',
			eventImage:
				'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',
			eventLogo:
				'https://cdn.discordapp.com/attachments/1054775421671055390/1105958725711319201/tsnakejake_A_cartoon_man_reading_a_mystical_book_with_an_emeral_d5f03067-6692-4152-8ade-37621c0776b5.png',

			serial: 'NO IDEA',
			totalSupply: null,
			transferrable: false
		}}
	/>
	<div class="column-2 center">
		<Button color="primary" size="large" width="extended" href="/event-generator"
			>Create an Event - it's free!</Button
		>
		<div class="column center">
			<span class="xsmall">FLOAT is 100% free</span>
			<span class="xsmall">We only charge a tiny percentage on payed FLOATs. </span>
		</div>
	</div>
</section>

<style lang="scss">
	section {
		position: relative;

		h1 {
			text-align: center;
		}

		p.h5 {
			text-align: center;
			color: var(--clr-text-main);
			max-width: 40ch;
		}
	}
</style>
