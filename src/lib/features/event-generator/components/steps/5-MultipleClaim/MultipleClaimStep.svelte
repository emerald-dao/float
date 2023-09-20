<script lang="ts">
	import { eventGeneratorData } from '../../../stores/EventGeneratorData';
	import RadioCards from '../../atoms/RadioCards.svelte';
	import StepComponentWrapper from '../../atoms/StepComponentWrapper.svelte';

	export let stepDataValid = true;

	const MULTIPLE_CLAIM_OPTIONS = [
		{
			value: false,
			title: 'Single Claim',
			description: 'Users can only claim this FLOAT once.'
		},
		{
			value: true,
			title: 'Multiple Claim',
			description: 'Users can claim this FLOAT multiple times.'
		}
	];
</script>

<StepComponentWrapper>
	<div class="column-4">
		<RadioCards
			options={MULTIPLE_CLAIM_OPTIONS}
			bind:selectedValue={$eventGeneratorData.multipleClaim}
		/>
	</div>
</StepComponentWrapper>
