<script lang="ts">
	import { fly } from 'svelte/transition';
	import { eventGeneratorSteps, eventGeneratorActiveStep } from './stores/EventGeneratorSteps';
	import { eventGeneratorData, generatedNft } from './stores/EventGeneratorData';
	import { setContext } from 'svelte';
	import StepButtons from './components/atoms/StepButtons.svelte';
	import Blur from '$lib/components/Blur.svelte';
	import { POWER_UPS } from './components/steps/6-PowerUps/powerUps';
	import { writable } from 'svelte/store';
	import Icon from '@iconify/svelte';
	import Float from '$lib/components/floats/Float.svelte';
	import CanBeEditedLater from './components/atoms/CanBeEditedLater.svelte';

	setContext('steps', eventGeneratorSteps);
	setContext('activeStep', eventGeneratorActiveStep);
	setContext('eventData', eventGeneratorData);

	const activePowerUp = writable('payment');

	let stepDataValid: boolean;

	setContext('activePowerUp', activePowerUp);

	$: powerUpsStep = $eventGeneratorActiveStep === 5;
	$: reviewStep = $eventGeneratorActiveStep === 6;
	$: activePowerUpComponent = POWER_UPS.find(
		(powerUp) => powerUp.type === $activePowerUp
	)?.component;
</script>

<section class:review-step={reviewStep}>
	<div class="step-component-wrapper" class:hide-on-medium={reviewStep}>
		<div>
			<svelte:component
				this={$eventGeneratorSteps[$eventGeneratorActiveStep].component}
				bind:stepDataValid
			/>
			{#if powerUpsStep}
				<div
					in:fly|local={{ x: -200, duration: 500, delay: 200 }}
					class="power-up-wrapper mobile-power-ups hide-on-medium"
				>
					<svelte:component this={activePowerUpComponent} />
				</div>
			{/if}
		</div>
		<StepButtons
			stepsStore={eventGeneratorSteps}
			activeStepStore={eventGeneratorActiveStep}
			bind:stepDataValid
		/>
	</div>
	<div class="right-column hide-on-small">
		<Blur color="tertiary" right="0" top="30%" />
		<Blur left="0" bottom="20%" />
		{#if reviewStep}
			<div class="review-step-wrapper">
				<svelte:component
					this={$eventGeneratorSteps[$eventGeneratorActiveStep].component}
					bind:stepDataValid
				/>
				<StepButtons
					stepsStore={eventGeneratorSteps}
					activeStepStore={eventGeneratorActiveStep}
					bind:stepDataValid
				/>
			</div>
		{:else if powerUpsStep}
			<div in:fly|local={{ x: -200, duration: 500, delay: 200 }} class="power-up-wrapper">
				<svelte:component this={activePowerUpComponent} />
			</div>
		{:else}
			<div class="column align-center ticket-wrapper" in:fly|local={{ x: 500, duration: 700 }}>
				<Float float={$generatedNft} showBack={$eventGeneratorActiveStep === 1} />
			</div>
			<span class="small click-to-flip row-2 align-center">
				<Icon icon="tabler:360" width="1.3rem" />
				Click ticket to flip
			</span>
		{/if}
	</div>
</section>

<style lang="scss">
	section {
		display: flex;
		flex: 1;
		padding-block: 0;

		@include mq(medium) {
			display: grid;
			grid-template-columns: 4fr 5fr;
			overflow: hidden;
		}

		&.review-step {
			display: flex;
			flex-direction: column;
			justify-content: space-between;
		}

		.step-component-wrapper {
			display: flex;
			flex: 1;
			height: 100%;
			flex-direction: column;
			justify-content: space-between;
			background-color: var(--clr-background-primary);
			border-right: 0.1px solid var(--clr-border-primary);
			overflow: hidden;
			box-shadow: 0px 0px 20px 0 var(--clr-shadow-primary);
			z-index: 2;
			padding: var(--space-9) var(--space-6);
			width: 100%;
			gap: var(--space-8);

			@include mq(medium) {
				padding: var(--space-18);
			}
		}

		.mobile-power-ups {
			padding-top: var(--space-6);
			border-top: 0.5px solid var(--clr-border-primary);
			margin-top: var(--space-6);
		}

		.review-step-wrapper {
			flex: 1;
			display: grid;
			grid-template-rows: 1fr auto;
		}

		.right-column {
			position: relative;
			flex-direction: column;
			justify-content: center;
			align-items: center;
			padding: var(--space-16);
			background-color: var(--clr-background-secondary);
			z-index: 0;
			flex: 1;

			&.hide-on-small {
				display: none;

				@include mq(medium) {
					display: flex;
				}
			}

			.ticket-wrapper,
			.power-up-wrapper {
				width: 100%;
			}

			.power-up-wrapper {
				height: 100%;
				margin-top: var(--space-16);
			}

			.click-to-flip {
				color: var(--clr-text-off);
				position: absolute;
				bottom: var(--space-8);
			}
		}
	}

	.hide-on-medium {
		@include mq(medium) {
			display: none !important;
		}
	}
</style>
