<script lang="ts">
	import { Label } from '@emerald-dao/component-library';
	import EventTypeCard from './atoms/EventTypeCard.svelte';
	import SectionHeading from '../atoms/SectionHeading.svelte';

	const EVENT_TYPES = [
		{
			name: 'Discord Meeting',
			description: 'Host a town hall in Discord and distribute FLOATs to attendees.',
			imageUrl: '/event-images/discord-meeting.png',
			icon: 'tabler:headphones'
		},
		{
			name: 'Twitter Space',
			description:
				'Host an interactive audio conversation on Twitter and distribute FLOATs to followers.',
			imageUrl: '/event-images/twitter-space.png',
			icon: 'tabler:brand-twitter'
		},
		{
			name: 'Gaming Competition',
			description:
				'Reward participants of a gaming competition with gold, silver, bronze, and participation medals.',
			imageUrl: '/event-images/gaming-competition.png',
			icon: 'tabler:device-gamepad'
		},
		{
			name: 'Product Presentation',
			description:
				'Close out a presentation by allowing the audience to claim a proof of attendance FLOAT.',
			imageUrl: '/event-images/product-presentation.png',
			icon: 'tabler:package'
		},
		{
			name: 'Course',
			description: 'Distribute educational certificates/diplomas to completionists of your course.',
			imageUrl: '/event-images/course.png',
			icon: 'tabler:book'
		},
		{
			name: 'Bootcamp',
			description:
				'Host an in-person or online educational bootcamp and give FLOATs to participants.',
			imageUrl: '/event-images/bootcamp.png',
			icon: 'tabler:device-laptop'
		},
		{
			name: 'Hackathon',
			description:
				'Host a hackathon and distribute gold, silver, bronze, and participation awards.',
			imageUrl: '/event-images/hackathon.png',
			icon: 'tabler:code'
		},
		{
			name: 'Sport Competition',
			description: 'Prove you attended the thrilling series-winning game with a FLOAT.',
			imageUrl: '/event-images/sport-competition.png',
			icon: 'tabler:play-football'
		},
		{
			name: 'Conference',
			description: 'Have your audience claim FLOATs for attending your event.',
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
