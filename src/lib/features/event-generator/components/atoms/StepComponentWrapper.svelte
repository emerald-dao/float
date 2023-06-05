<script lang="ts">
	import { fly } from 'svelte/transition';
	import StepIntro from './StepIntro.svelte';
	import { eventGeneratorActiveStep, eventGeneratorSteps } from '../../stores/EventGeneratorSteps';
</script>

<div in:fly={{ duration: 700, x: 20 }} class="column-7">
	<StepIntro
		title={$eventGeneratorSteps[$eventGeneratorActiveStep].title}
		description={$eventGeneratorSteps[$eventGeneratorActiveStep].description}
	/>
	<slot />
</div>
