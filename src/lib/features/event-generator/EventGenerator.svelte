<script>
	import { eventGeneratorSteps, eventGeneratorActiveStep } from './stores/EventGeneratorSteps';
	import { eventGeneratorData } from './stores/EventGeneratorData';
	import { setContext } from 'svelte';
	import StepButtons from './components/atoms/StepButtons.svelte';
	import FloatTicket from '$lib/components/floats/FloatTicket.svelte';
	import StepIntro from './components/atoms/StepIntro.svelte';

	setContext('steps', eventGeneratorSteps);
	setContext('activeStep', eventGeneratorActiveStep);
	setContext('eventData', eventGeneratorData);
</script>

<section>
	<div class="step-component-wrapper">
		<div class="column-8">
			<StepIntro
				title={$eventGeneratorSteps[$eventGeneratorActiveStep].title}
				description={$eventGeneratorSteps[$eventGeneratorActiveStep].description}
			/>
			<svelte:component this={$eventGeneratorSteps[$eventGeneratorActiveStep].component} />
		</div>
		<StepButtons stepsStore={eventGeneratorSteps} activeStepStore={eventGeneratorActiveStep} />
	</div>
	<div />
</section>

<style lang="scss">
	section {
		display: grid;
		grid-template-columns: 1fr 1fr;
		gap: var(--space-16);
		padding-block: 0;
		flex: 1;

		.step-component-wrapper {
			display: flex;
			flex-direction: column;
			justify-content: space-between;
			background-color: var(--clr-background-secondary);
			border-right: 0.1px solid var(--clr-border-primary);
			padding: var(--space-18);
		}
	}
</style>
