<script lang="ts">
	import SectionHeading from './atoms/SectionHeading.svelte';

	const STEPS = [
		{
			title: 'Create an event',
			description:
				'Create an event and mint a float for it. You can choose from a variety of event types.'
		},
		{
			title: 'Attend the event',
			description: 'Attend the event and get your float signed by the event organizer.'
		},
		{
			title: 'Collect your float',
			description: 'Collect your float and add it to your collection.'
		}
	];
</script>

<section class="container center column-10">
	<SectionHeading
		title="Simple and Powerful"
		description="Launch your event in three simple steps."
	/>
	<div class="cards-wrapper">
		{#each STEPS as step, i}
			<div class="step-card">
				<div class="row-2 align-center">
					<span class="step-number w-medium">
						{i + 1}
					</span>
					<h4 class="h5 w-medium">{step.title}</h4>
				</div>
				<p>
					{step.description}
				</p>
			</div>
		{/each}
	</div>
</section>

<style type="scss">
	.cards-wrapper {
		display: flex;
		flex-direction: column;
		gap: var(--space-8);

		@include mq('small') {
			display: grid;
			grid-template-columns: repeat(3, 1fr);
			width: 100%;
		}

		.step-card {
			background-color: var(--clr-background-secondary);
			padding: var(--space-8);
			border-radius: var(--radius-4);
			display: flex;
			flex-direction: column;
			gap: var(--space-3);

			.step-number {
				background-color: var(--clr-primary-badge);
				color: var(--clr-primary-main);
				font-size: var(--font-size-4);
				height: 2rem;
				width: 2rem;
				display: flex;
				justify-content: center;
				align-items: center;
				border-radius: 50%;
			}
		}
	}
</style>
