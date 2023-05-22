<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import { DropZone } from '@emerald-dao/component-library';
	import StepComponentWrapper from '../../atoms/StepComponentWrapper.svelte';
</script>

<StepComponentWrapper>
	<DropZone
		bind:bindValue={$eventGeneratorData.image}
		name="float-image"
		maxAmountOfFiles={1}
		accept={['image/png', 'image/jpeg', 'image/jpg']}
	/>
</StepComponentWrapper>
