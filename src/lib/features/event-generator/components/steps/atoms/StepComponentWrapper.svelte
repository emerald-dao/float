<script lang="ts">
	import { fly } from 'svelte/transition';
	import StepIntro from './StepIntro.svelte';
	import {
		eventGeneratorActiveStep,
		eventGeneratorSteps
	} from '../../../stores/EventGeneratorSteps';

	export let alignCenter = false;
	export let fitContent = false;
</script>

<div
	in:fly={{ duration: 700, x: 20 }}
	class="column-7"
	class:align-center={alignCenter}
	class:fit-content={fitContent}
>
	<StepIntro
		title={$eventGeneratorSteps[$eventGeneratorActiveStep].title}
		description={$eventGeneratorSteps[$eventGeneratorActiveStep].description}
		canBeEditedLater={$eventGeneratorSteps[$eventGeneratorActiveStep].canBeEditedLater}
		{alignCenter}
	/>
	<slot />
</div>

<style lang="scss">
	div {
		height: 100%;
		flex: 1;
	}

	.fit-content {
		height: fit-content;
	}
</style>
