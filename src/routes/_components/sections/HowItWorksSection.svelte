<script lang="ts">
	import SectionHeading from './atoms/SectionHeading.svelte';

	const STEPS = [
		{
			title: 'Create an event',
			description:
				'Create a new FLOAT event with special properties. You can choose from a variety of event types.'
		},
		{
			title: 'Attend the event',
			description: "Attend the event and visit the event's claim page."
		},
		{
			title: 'Collect your FLOAT',
			description: 'Mint your unique FLOAT and add it to your collection.'
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
			<div class="card-primary">
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

<style lang="scss">
	.cards-wrapper {
		display: flex;
		flex-direction: column;
		gap: var(--space-8);

		@include mq('small') {
			display: grid;
			grid-template-columns: repeat(3, 1fr);
			width: 100%;
		}

		.card-primary {
			display: flex;
			flex-direction: column;
			gap: var(--space-2);
		}

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
</style>
