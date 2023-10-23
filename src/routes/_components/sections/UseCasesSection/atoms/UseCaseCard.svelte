<script lang="ts">
	import Float from '$lib/components/floats/Float.svelte';

	export let title: string;
	export let description: string;
	export let logo: string;

	let hover = false;
</script>

<div class="card-primary">
	<div class="column-3">
		<div class="row-2 align-center">
			<img src={logo} alt="Logo" width="26" />
			<h4 class="h5 w-medium">{title}</h4>
		</div>
		<p>
			{description}
		</p>
	</div>
	<div class="float-wrapper">
		<Float
			float={{
				id: '0x0000000000',
				eventId: '0x0000000000',
				dateReceived: '2021-09-01T00:00:00.000Z',
				eventDescription: 'Flow Hackathon',
				eventHost: 'Flow',
				eventImage: 'https://pbs.twimg.com/profile_images/1363521327467156480/8XZdZv2I_400x400.jpg',
				backImage: 'https://pbs.twimg.com/profile_images/1363521327467156480/8XZdZv2I_400x400.jpg',
				eventName: 'Flow Hackathon',
				originalRecipient: '0x0000000000',
				serial: '0',
				totalSupply: null,
				transferrable: false,
				eventType: 'hackathon',
				extraMetadata: {
					medalType: 'gold'
				}
			}}
		/>
	</div>
</div>

<style lang="scss">
	.card-primary {
		display: flex;
		flex-direction: column;
		gap: var(--space-12);
		overflow: hidden;
		position: relative;
		height: 300px;

		&:hover {
			gap: var(--space-5);
		}
	}
</style>
