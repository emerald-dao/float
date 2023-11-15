<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import { DropZone, InputWrapper } from '@emerald-dao/component-library';
	import validationSuite from './validation';
	import type { SuiteRunResult } from 'vest';
	import {
		EVENT_TYPES,
		EVENT_TYPE_DETAILS,
		type EventType
	} from '$lib/types/event/event-type.type';
	import { onMount } from 'svelte';
	import StepComponentWrapper from '../atoms/StepComponentWrapper.svelte';

	export let stepDataValid: boolean;

	const handleChange = (input: Event) => {
		const target = input.target as HTMLInputElement;

		res = validationSuite($eventGeneratorData, target.name);

		(res as SuiteRunResult).done((result) => {
			res = result;
		});
	};

	const handleEventTypeChange = (input: Event) => {
		const target = input.target as HTMLInputElement;
		$eventGeneratorData.eventType = target.value as EventType;
		$eventGeneratorData.certificateType =
			EVENT_TYPE_DETAILS[target.value as EventType].certificateType;
	};

	let res = validationSuite.get();

	onMount(() => {
		validationSuite.reset();

		if ($eventGeneratorData.name.length > 0 && $eventGeneratorData.description.length > 0) {
			res = validationSuite($eventGeneratorData);
		}
	});

	$: stepDataValid = res.isValid() && $eventGeneratorData.logo.length > 0;
</script>

<StepComponentWrapper>
	<div>
		<div class="column-1">
			<label for="event-type">Event Type</label>
			<select name="event-type" id="event-type" on:change={handleEventTypeChange}>
				{#each EVENT_TYPES as eventType}
					<option value={eventType}>
						{EVENT_TYPE_DETAILS[eventType].eventTypeName} -
						<i>{EVENT_TYPE_DETAILS[eventType].certificateType}</i>
					</option>
				{/each}
			</select>
		</div>
		<p class="xsmall margin-bottom">
			<i>
				If you want your FLOAT to display as an image (instead of a ticket), you can select that
				later on.
			</i>
		</p>
		<InputWrapper
			label="Event Name"
			name="event-name"
			errors={res.getErrors('event-name')}
			isValid={res.isValid('event-name')}
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
		<InputWrapper
			label="Event Description"
			name="event-description"
			errors={res.getErrors('event-description')}
			isValid={res.isValid('event-description')}
		>
			<textarea
				class="description"
				bind:value={$eventGeneratorData.description}
				name="event-description"
				on:input={handleChange}
				placeholder="This event symbalizes..."
				rows="3"
			/>
		</InputWrapper>
		<div>
			<label for="event-logo">Event Logo</label>
			<DropZone
				bind:bindValue={$eventGeneratorData.logo}
				name="event-logo"
				maxAmountOfFiles={1}
				maxFileSizeInMB={20}
				accept={['image/png', 'image/jpeg', 'image/jpg', 'image/gif']}
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

	.margin-bottom {
		margin-bottom: var(--space-6);
	}

	.description {
		border: none;
	}
</style>
