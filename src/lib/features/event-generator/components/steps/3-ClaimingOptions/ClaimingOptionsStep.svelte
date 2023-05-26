<script lang="ts">
	import { eventGeneratorData } from './../../../stores/EventGeneratorData';
	import RadioCards from '../../atoms/RadioCards.svelte';
	import StepComponentWrapper from '../../atoms/StepComponentWrapper.svelte';

	export let stepDataValid = true;

	const CLAIMING_OPTIONS = [
		{
			value: false,
			title: 'Non-claimable',
			description: 'You will be responsible of distributing the FLOAT to accounts.'
		},
		{
			value: true,
			title: 'Claimable',
			description: 'Your audience can claim this FLOAT.'
		}
	];
</script>

<StepComponentWrapper>
	<div class="column-4">
		<RadioCards options={CLAIMING_OPTIONS} bind:selectedValue={$eventGeneratorData.claimable} />
	</div>
</StepComponentWrapper>
