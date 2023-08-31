<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import { EVENT_TYPES, EVENT_TYPE_DETAILS } from '$lib/types/event/event-type.type';
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
	<div>
		<div class="column">
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
					<option value={eventType}>{EVENT_TYPE_DETAILS[eventType].eventTypeName}</option>
				{/each}
			</select>
		</div>
		<div class="event-logo-wrapper">
			<label for="event-logo"> Event logo </label>
			<DropZone
				bind:bindValue={$eventGeneratorData.logo}
				name="event-logo"
				maxAmountOfFiles={1}
				accept={['image/png', 'image/jpeg', 'image/jpg']}
			/>
		</div>
	</div>
</StepComponentWrapper>

<style lang="scss">
	label {
		margin-bottom: 2px;
	}

	select {
		padding: var(--space-2);
		font-size: var(--font-size-1);
	}

	.event-logo-wrapper {
		margin-top: var(--space-6);
	}
</style>
