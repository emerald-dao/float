<script lang="ts">
	import { eventGeneratorData } from './../../../stores/EventGeneratorData';
	import RadioCards from '../../atoms/RadioCards.svelte';
	import StepComponentWrapper from '../../atoms/StepComponentWrapper.svelte';

	const TRADING_OPTIONS = [
		{
			value: false,
			title: 'Soulbound',
			description: 'This FLOAT cannot be traded nor transferred.'
		},
		{
			value: true,
			title: 'Tradeable',
			description: 'This FLOAT can be traded and/or transferred by his owner.'
		}
	];
</script>

<StepComponentWrapper>
	<div class="column-4">
		<RadioCards options={TRADING_OPTIONS} bind:selectedValue={$eventGeneratorData.transferrable} />
	</div>
</StepComponentWrapper>
