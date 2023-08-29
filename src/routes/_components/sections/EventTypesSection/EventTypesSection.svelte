<script lang="ts">
	import { Label } from '@emerald-dao/component-library';
	import EventTypeCard from './atoms/EventTypeCard.svelte';
	import SectionHeading from '../atoms/SectionHeading.svelte';

	const EVENT_TYPES = [
		{
			name: 'Discord Meeting',
			description:
				'Connect and collaborate with your community in a Discord meeting with voice and text chat.',
			imageUrl: '/event-images/discord-meeting.png',
			icon: 'tabler:headphones'
		},
		{
			name: 'Twitter Space',
			description:
				'Host an interactive audio conversation on Twitter with your followers using Twitter Spaces.',
			imageUrl: '/event-images/twitter-space.png',
			icon: 'tabler:brand-twitter'
		},
		{
			name: 'Gaming Competition',
			description:
				'Organize an exciting gaming competition where players compete against each other for victory.',
			imageUrl: '/event-images/gaming-competition.png',
			icon: 'tabler:device-gamepad'
		},
		{
			name: 'Product Presentation',
			description:
				'Showcase your latest product to a global audience with a captivating and informative presentation.',
			imageUrl: '/event-images/product-presentation.png',
			icon: 'tabler:package'
		},
		{
			name: 'Course',
			description:
				'Offer an educational course to share your expertise and knowledge with eager learners.',
			imageUrl: '/event-images/course.png',
			icon: 'tabler:book'
		},
		{
			name: 'Hackathon',
			description:
				'Host a hackathon event where programmers collaborate intensively on software projects.',
			imageUrl: '/event-images/hackathon.png',
			icon: 'tabler:code'
		},
		{
			name: 'Sport Competition',
			description:
				'Organize a sports competition that brings athletes together to showcase their skills and sportsmanship.',
			imageUrl: '/event-images/sport-competition.png',
			icon: 'tabler:play-football'
		},
		{
			name: 'Conference',
			description: 'Host a conference with live video and chat.',
			imageUrl: '/event-images/conference-event.png',
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
	{#each EVENT_TYPES as event}
		{#if event.name === selectedEvent.name}
			<EventTypeCard
				imageUrl={event.imageUrl}
				title={event.name}
				description={event.description}
				icon={event.icon}
			/>
		{/if}
	{/each}
	<div class="labels-wrapper">
		{#each EVENT_TYPES as event}
			<div on:click={() => (selectedEvent = event)} class="label-button-wrapper">
				<Label
					size="medium"
					color={selectedEvent.name === event.name ? 'tertiary' : 'neutral'}
					iconLeft={event.icon}
				>
					{event.name}
				</Label>
			</div>
		{/each}
	</div>
</section>

<style lang="scss">
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
