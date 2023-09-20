<script lang="ts">
	import { fly } from 'svelte/transition';
	import StepIntro from './StepIntro.svelte';
	import {
		eventGeneratorActiveStep,
		eventGeneratorSteps
	} from '../../../stores/EventGeneratorSteps';

	export let alignCenter = false;
</script>

<div in:fly={{ duration: 700, x: 20 }} class="column-7" class:align-center={alignCenter}>
	<StepIntro
		title={$eventGeneratorSteps[$eventGeneratorActiveStep].title}
		description={$eventGeneratorSteps[$eventGeneratorActiveStep].description}
		canBeEditedLater={$eventGeneratorSteps[$eventGeneratorActiveStep].canBeEditedLater}
		{alignCenter}
	/>
	<slot />
</div>
