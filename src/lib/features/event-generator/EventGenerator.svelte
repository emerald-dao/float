<script>
	import { eventGeneratorSteps, eventGeneratorActiveStep } from './stores/EventGeneratorSteps';
	import { eventGeneratorData, generatedNft } from './stores/EventGeneratorData';
	import { setContext } from 'svelte';
	import StepButtons from './components/atoms/StepButtons.svelte';
	import FloatTicket from '$lib/components/floats/FloatTicket.svelte';
	import Blur from '$lib/components/Blur.svelte';

	setContext('steps', eventGeneratorSteps);
	setContext('activeStep', eventGeneratorActiveStep);
	setContext('eventData', eventGeneratorData);
</script>

<section>
	<div class="step-component-wrapper">
		<svelte:component this={$eventGeneratorSteps[$eventGeneratorActiveStep].component} />
		<StepButtons stepsStore={eventGeneratorSteps} activeStepStore={eventGeneratorActiveStep} />
	</div>
	<div class="generated-nft-wrapper">
		<Blur color="tertiary" right="0" top="30%" />
		<Blur left="0" bottom="20%" />
		<FloatTicket float={$generatedNft} showBack={$eventGeneratorActiveStep === 1} />
	</div>
</section>

<style lang="scss">
	section {
		display: grid;
		grid-template-columns: 1fr 1fr;
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

		.generated-nft-wrapper {
			position: relative;
			display: flex;
			flex-direction: column;
			justify-content: center;
			align-items: center;
			padding: var(--space-16);
		}
	}
</style>
