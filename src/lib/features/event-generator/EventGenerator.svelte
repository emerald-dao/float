<script>
	import { fly } from 'svelte/transition';
	import { eventGeneratorSteps, eventGeneratorActiveStep } from './stores/EventGeneratorSteps';
	import { eventGeneratorData, generatedNft } from './stores/EventGeneratorData';
	import { setContext } from 'svelte';
	import StepButtons from './components/atoms/StepButtons.svelte';
	import FloatTicket from '$lib/components/floats/FloatTicket.svelte';
	import Blur from '$lib/components/Blur.svelte';
	import POWER_UPS from './components/steps/5-PowerUps/powerUps';
	import { writable } from 'svelte/store';

	setContext('steps', eventGeneratorSteps);
	setContext('activeStep', eventGeneratorActiveStep);
	setContext('eventData', eventGeneratorData);

	const activePowerUp = writable('payment');

	setContext('activePowerUp', activePowerUp);

	$: powerUpsStep = $eventGeneratorActiveStep === 4;
	$: activePowerUpComponent = POWER_UPS.find(
		(powerUp) => powerUp.type === $activePowerUp
	)?.component;
</script>

<section>
	<div class="step-component-wrapper">
		<svelte:component this={$eventGeneratorSteps[$eventGeneratorActiveStep].component} />
		<StepButtons stepsStore={eventGeneratorSteps} activeStepStore={eventGeneratorActiveStep} />
	</div>
	<div class="generated-nft-wrapper">
		<Blur color="tertiary" right="0" top="30%" />
		<Blur left="0" bottom="20%" />
		{#if !powerUpsStep}
			<div transition:fly|local={{ x: 500, duration: 700 }}>
				<FloatTicket float={$generatedNft} showBack={$eventGeneratorActiveStep === 1} />
			</div>
		{:else}
			<div in:fly|local={{ x: -200, duration: 500, delay: 500 }} style="position: absolute">
				<svelte:component this={activePowerUpComponent} />
			</div>
		{/if}
	</div>
</section>

<style lang="scss">
	section {
		padding-block: 0;
		flex: 1;
		display: grid;
		grid-template-columns: 4fr 5fr;
		overflow: hidden;

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
