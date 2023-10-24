<script lang="ts">
	import SectionHeading from '../atoms/SectionHeading.svelte';
	import UseCaseCard from './atoms/UseCaseCard.svelte';

	const USE_CASES = [
		{
			title: 'Flow Hackathons',
			name: 'Flow to the Future Award',
			logo: '/flow-logo.png',
			backImage: '/example-event-images/flow-back-image.jpeg',
			description:
				'The official Flow Blockchain team uses FLOATs to certify the winners of their hackathons.',
			eventType: 'hackathon'
		},
		{
			title: 'Dapper Wallet PFP',
			logo: '/example-event-images/hbd_topshot.gif',
			description: 'Users love to use a FLOAT as their Dapper Wallet profile video.',
			eventType: 'other',
			visibilityMode: 'picture'
		},
		{
			title: 'NFT Day 2023',
			name: 'Attending NFT Day 2023',
			logo: '/example-event-images/nft-day-2023.gif',
			backImage: '/example-event-images/nft-day-2023.gif',
			description:
				'Everyone who showed up to NFT Day 2023 in person or online received a commemorative ticket.',
			eventType: 'other'
		},
		{
			title: 'Emerald Academy Certificate',
			name: 'Beginner Cadence Course - Certificate',
			logo: '/ea-logo.png',
			backImage: '/example-event-images/ec-back-image.jpeg',
			description:
				'Developers who completed the Beginner Cadence Course received a verifiable certificate for their resume.',
			eventType: 'course'
		},
		{
			title: 'Roomz Relief Fundraiser',
			name: 'Donated to Roomz Relief',
			logo: '/example-event-images/roomz-fundraiser.png',
			backImage: '/example-event-images/roomz-fundraiser.png',
			description:
				'A paid FLOAT used to raise funds for a community impacted by Tropical Storm Megi in Barangay, Philippines during April 2022.',
			eventType: 'other'
		},
		{
			title: 'Driverz Racing League',
			name: 'Driverz Racing League: S2W7',
			logo: '/example-event-images/driverz-event.png',
			backImage: '/example-event-images/driverz-back-image.png',
			description:
				'Community members got to claim this FLOAT for attending a live stream with announcements for the upcoming season.',
			eventType: 'other'
		}
	];
</script>

<section class="container center column-10">
	<SectionHeading
		title="Find your perfect use case"
		description="Some examples on how our users use FLOATs."
	/>
	{#each Array(Math.ceil(USE_CASES.length / 2)) as _, ind}
		<div class="cards-wrapper" class:inverse={ind % 2 !== 0}>
			{#each USE_CASES as step, i}
				{#if i >= ind * 2 && i < ind * 2 + 2}
					<UseCaseCard
						title={step.title}
						description={step.description}
						logo={step.logo}
						eventType={step.eventType}
						visibilityMode={step.visibilityMode}
						backImage={step.backImage}
						name={step.name}
					/>
				{/if}
			{/each}
		</div>
	{/each}
</section>

<style lang="scss">
	.cards-wrapper {
		display: flex;
		flex-direction: column;
		gap: var(--space-8);

		@include mq('small') {
			display: grid;
			grid-template-columns: 9fr 8fr;
			width: 100%;

			&.inverse {
				grid-template-columns: 8fr 9fr;
			}
		}
	}
</style>
