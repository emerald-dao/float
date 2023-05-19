<script>
	import { eventGeneratorSteps, eventGeneratorActiveStep } from './stores/EventGeneratorSteps';
	import { eventGeneratorData } from './stores/EventGeneratorData';
	import { setContext } from 'svelte';

	setContext('steps', eventGeneratorSteps);
	setContext('activeStep', eventGeneratorActiveStep);
	setContext('eventData', eventGeneratorData);
</script>

<svelte:component this={$eventGeneratorSteps[$eventGeneratorActiveStep].component} />
