<script lang="ts">
	import { eventGeneratorData } from '../../../stores/EventGeneratorData';
	import RadioCards from '../../atoms/RadioCards.svelte';
	import StepComponentWrapper from '../../atoms/StepComponentWrapper.svelte';

	export let stepDataValid = true;

	const VISIBILITY_OPTIONS = [
		{
			value: 'certificate',
			title: 'Certificate',
			description: 'This FLOAT will be showed as a FLOAT certificate.'
		},
		{
			value: 'picture',
			title: 'Picture',
			description:
				'This FLOAT will be showed as a picture. Select this option if you want your FLOAT to be your dapper labs profile picture.'
		}
	];
</script>

<StepComponentWrapper>
	<div class="column-4">
		<RadioCards
			options={VISIBILITY_OPTIONS}
			bind:selectedValue={$eventGeneratorData.visibilityMode}
		/>
	</div>
</StepComponentWrapper>
