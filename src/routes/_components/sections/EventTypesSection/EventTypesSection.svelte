<script>
	import { Label } from '@emerald-dao/component-library';
	import EventTypeCard from './atoms/EventTypeCard.svelte';
	import SectionHeading from '../atoms/SectionHeading.svelte';

	const EVENT_TYPES = [
		{
			name: 'Online Event',
			description: 'Host an online event with live video and chat.',
			imageUrl: '/event-images/conference-event.jpg',
			icon: 'tabler:home'
		},
		{
			name: 'In-person Event',
			description: 'Host an in-person event with live video and chat.',
			imageUrl: '/event-images/conference-event.jpg',
			icon: 'tabler:home'
		},
		{
			name: 'Hybrid Event',
			description: 'Host a hybrid event with live video and chat.',
			imageUrl: '/event-images/conference-event.jpg',
			icon: 'tabler:home'
		},
		{
			name: 'Virtual Event',
			description: 'Host a virtual event with live video and chat.',
			imageUrl: '/event-images/conference-event.jpg',
			icon: 'tabler:home'
		},
		{
			name: 'Webinar',
			description: 'Host a webinar with live video and chat.',
			imageUrl: '/event-images/conference-event.jpg',
			icon: 'tabler:home'
		},
		{
			name: 'Workshop',
			description: 'Host a workshop with live video and chat.',
			imageUrl: '/event-images/conference-event.jpg',
			icon: 'tabler:home'
		},
		{
			name: 'Meetup',
			description: 'Host a meetup with live video and chat.',
			imageUrl: '/event-images/conference-event.jpg',
			icon: 'tabler:home'
		},
		{
			name: 'Conference',
			description: 'Host a conference with live video and chat.',
			imageUrl: '/event-images/conference-event.jpg',
			icon: 'tabler:home'
		}
	];

	let selectedEvent = EVENT_TYPES[0];
</script>

<section class="container-small center column-10">
	<SectionHeading
		title="We've got you covered"
		description="Create a unique and valuable experience for event attendees, while increasing engagement and
			trust for event creators."
	/>
	<EventTypeCard
		imageUrl={selectedEvent.imageUrl}
		title={selectedEvent.name}
		description={selectedEvent.description}
		icon={selectedEvent.icon}
	/>
	<div class="labels-wrapper">
		{#each EVENT_TYPES as event}
			<div on:click={() => (selectedEvent = event)} class="label-button-wrapper">
				<Label
					size="large"
					color={selectedEvent.name === event.name ? 'tertiary' : 'neutral'}
					iconLeft={event.icon}
				>
					{event.name}
				</Label>
			</div>
		{/each}
	</div>
</section>

<style type="scss">
	.labels-wrapper {
		display: flex;
		flex-wrap: wrap;
		justify-content: center;
		gap: var(--space-4);
		flex-direction: row;

		.label-button-wrapper {
			cursor: pointer;
			user-select: none;
		}
	}
</style>
