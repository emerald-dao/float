<script lang="ts">
	import Float from '$lib/components/floats/Float.svelte';
	import type { EventType } from '$lib/types/event/event-type.type';

	export let title: string;
	export let description: string;
	export let logo: string;
	export let eventType: EventType;
	export let backImage: string;
	export let name: string;
	export let visibilityMode: 'certificate' | 'picture' = 'certificate';

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
				eventId: '123',
				dateReceived: '2021-09-01T00:00:00.000Z',
				eventDescription: 'Flow Hackathon',
				eventHost: 'Flow',
				eventImage: logo,
				backImage,
				eventName: name || title,
				originalRecipient: '0x0000000000',
				serial: '0',
				totalSupply: null,
				transferrable: false,
				eventType,
				extraMetadata: {
					medalType: 'gold'
				},
				visibilityMode
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

		.float-wrapper {
			display: flex;
			justify-content: center;
			align-items: center;
		}

		&:hover {
			gap: var(--space-5);
		}
	}
</style>
