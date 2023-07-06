<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import { EVENT_TYPES } from '$lib/types/event/even-type.type';
	import { DropZone, InputWrapper } from '@emerald-dao/component-library';
	import StepComponentWrapper from '../../atoms/StepComponentWrapper.svelte';
	import validationSuite from './validation';
	import type { SuiteRunResult } from 'vest';

	export let stepDataValid: boolean;

	const handleChange = (input: Event) => {
		const target = input.target as HTMLInputElement;

		res = validationSuite($eventGeneratorData, target.name);

		(res as SuiteRunResult).done((result) => {
			res = result;
		});
	};

	let res = validationSuite.get();

	$: stepDataValid = res.isValid() && $eventGeneratorData.logo.length > 0;
</script>

<StepComponentWrapper>
	<div class="column-1">
		<InputWrapper
			label="Event name"
			name="event-name"
			errors={res.getErrors('event-name')}
			isValid={res.isValid('event-name')}
			required={true}
		>
			<input
				type="text"
				bind:value={$eventGeneratorData.name}
				name="event-name"
				on:input={handleChange}
				maxlength="30"
				placeholder="Flow hackathon"
			/>
		</InputWrapper>
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
