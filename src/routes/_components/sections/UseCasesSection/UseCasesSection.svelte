<script lang="ts">
	import SectionHeading from '../atoms/SectionHeading.svelte';
	import UseCaseCard from './atoms/UseCaseCard.svelte';

	const USE_CASES = [
		{
			title: 'Flow Hackathons',
			logo: '/flow-logo.png',
			description:
				'The official Flow Blockchain team uses FLOATs to certify the winners of their hackathons.'
		},
		{
			title: 'Flow Hackathons',
			logo: '/flow-logo.png',

			description:
				'The official Flow Blockchain team uses FLOATs to certify the winners of their hackathons.'
		},
		{
			title: 'Flow Hackathons',
			logo: '/flow-logo.png',

			description:
				'The official Flow Blockchain team uses FLOATs to certify the winners of their hackathons.'
		},
		{
			title: 'Flow Hackathons',
			logo: '/flow-logo.png',

			description:
				'The official Flow Blockchain team uses FLOATs to certify the winners of their hackathons.'
		},
		{
			title: 'Flow Hackathons',
			logo: '/flow-logo.png',

			description:
				'The official Flow Blockchain team uses FLOATs to certify the winners of their hackathons.'
		},
		{
			title: 'Flow Hackathons',
			logo: '/flow-logo.png',

			description:
				'The official Flow Blockchain team uses FLOATs to certify the winners of their hackathons.'
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
					<UseCaseCard title={step.title} description={step.description} logo={step.logo} />
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
