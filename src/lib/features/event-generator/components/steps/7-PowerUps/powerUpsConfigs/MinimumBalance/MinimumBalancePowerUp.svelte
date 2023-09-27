<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import { CurrencyInput } from '@emerald-dao/component-library';
	import PowerUpConfigWrapper from '../../atoms/PowerUpConfigWrapper.svelte';
	import { type PowerUpGeneratorData, POWER_UPS, powerUpsValidations } from '../../powerUps';
	import type { SuiteRunResult } from 'vest';
	import validationSuite from './validation';

	const powerUpData = POWER_UPS['minimumBalance'];

	$: isActive = $eventGeneratorData.powerups.minimumBalance.active;

	const handleChange = () => {
		res = validationSuite($eventGeneratorData);

		(res as SuiteRunResult).done((result) => {
			res = result;

			$powerUpsValidations.minimumBalance = res.isValid();
		});
	};

	let res = validationSuite.get();
</script>

<PowerUpConfigWrapper {powerUpData} powerUpType="minimumBalance">
	<div>
		<CurrencyInput
			currency="FLOW"
			label="Minimum FLOAT balance"
			name="minimum-balance"
			disabled={!isActive}
			isValid={res.isValid()}
			errors={res.getErrors('minimum-balance')}
			bind:value={$eventGeneratorData.powerups.minimumBalance.data}
			on:input={handleChange}
		/>
	</div>
</PowerUpConfigWrapper>
