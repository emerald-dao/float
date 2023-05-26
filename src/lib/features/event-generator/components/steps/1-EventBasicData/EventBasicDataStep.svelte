<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import { EVENT_TYPES } from '$lib/types/event/even-type.type';
	import { DropZone } from '@emerald-dao/component-library';
	import StepComponentWrapper from '../../atoms/StepComponentWrapper.svelte';
</script>

<StepComponentWrapper>
	<div class="column-1">
		<label for="event-name">Event name</label>
		<input type="text" bind:value={$eventGeneratorData.name} name="event-name" />
	</div>
	<div class="column-1">
		<label for="event-type">Event type</label>
		<select name="event-type" id="event-type" bind:value={$eventGeneratorData.eventType}>
			{#each EVENT_TYPES as eventType}
				<option value={eventType}>{eventType}</option>
			{/each}
		</select>
	</div>
	<div class="column-1">
		<label for="event-logo"> Event logo </label>
		<DropZone
			bind:bindValue={$eventGeneratorData.logo}
			name="event-logo"
			maxAmountOfFiles={1}
			accept={['image/png', 'image/jpeg', 'image/jpg']}
		/>
	</div>
</StepComponentWrapper>
