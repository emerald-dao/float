<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import { DropZone } from '@emerald-dao/component-library';
	import StepComponentWrapper from '../atoms/StepComponentWrapper.svelte';

	export let stepDataValid: boolean;

	$: stepDataValid = $eventGeneratorData.image.length > 0;
</script>

<StepComponentWrapper>
	<DropZone
		bind:bindValue={$eventGeneratorData.image}
		name="float-image"
		maxAmountOfFiles={1}
		maxFileSizeInMB={20}
		accept={['image/png', 'image/jpeg', 'image/jpg', 'image/gif']}
	/>
</StepComponentWrapper>
