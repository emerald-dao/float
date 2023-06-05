<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import PowerUpConfigWrapper from '../../atoms/PowerUpConfigWrapper.svelte';
	import POWER_UPS, { type PowerUp } from '../../powerUps';
	import { CurrencyInput } from '@emerald-dao/component-library';
	import validationSuite from './validation';
	import type { SuiteRunResult } from 'vest';

	const handleChange = () => {
		res = validationSuite($eventGeneratorData);

		(res as SuiteRunResult).done((result) => {
			res = result;
		});
	};

	let res = validationSuite.get();

	const powerUpData = POWER_UPS.find((powerUp) => powerUp.type === 'payment') as PowerUp<'payment'>;
</script>

<PowerUpConfigWrapper {powerUpData}>
	<div>
		<CurrencyInput
			currency="FLOW"
			label="FLOAT price"
			name="payment"
			isValid={res.isValid()}
			errors={res.getErrors('payment')}
			bind:value={$eventGeneratorData.powerups.payment.data}
			on:input={handleChange}
		/>
	</div>
</PowerUpConfigWrapper>
