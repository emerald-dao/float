<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import PowerUpConfigWrapper from '../../atoms/PowerUpConfigWrapper.svelte';
	import { type PowerUpGeneratorData, POWER_UPS, powerUpsValidations } from '../../powerUps';
	import { CurrencyInput } from '@emerald-dao/component-library';
	import validationSuite from './validation';
	import type { SuiteRunResult } from 'vest';

	const powerUpData = POWER_UPS.find(
		(powerUp) => powerUp.type === 'payment'
	) as PowerUpGeneratorData<'payment'>;

	$: isActive = $eventGeneratorData.powerups.payment.active;

	const handleChange = () => {
		res = validationSuite($eventGeneratorData);

		(res as SuiteRunResult).done((result) => {
			res = result;

			$powerUpsValidations.payment = res.isValid();
		});
	};

	let res = validationSuite.get();
</script>

<PowerUpConfigWrapper {powerUpData}>
	<div>
		<CurrencyInput
			currency="FLOW"
			label="FLOAT price"
			name="payment"
			disabled={!isActive}
			isValid={res.isValid()}
			errors={res.getErrors('payment')}
			bind:value={$eventGeneratorData.powerups.payment.data}
			on:input={handleChange}
		/>
	</div>
</PowerUpConfigWrapper>
