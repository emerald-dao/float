<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import { CurrencyInput } from '@emerald-dao/component-library';
	import PowerUpConfigWrapper from '../../atoms/PowerUpConfigWrapper.svelte';
	import { type PowerUp, POWER_UPS, powerUpsValidations } from '../../powerUps';
	import type { SuiteRunResult } from 'vest';
	import validationSuite from './validation';

	const powerUpData = POWER_UPS.find(
		(powerUp) => powerUp.type === 'minimumBalance'
	) as PowerUp<'minimumBalance'>;

	const handleChange = () => {
		res = validationSuite($eventGeneratorData);

		(res as SuiteRunResult).done((result) => {
			res = result;

			$powerUpsValidations.minimumBalance = res.isValid();
		});
	};

	let res = validationSuite.get();
</script>

<PowerUpConfigWrapper {powerUpData}>
	<div>
		<CurrencyInput
			currency="FLOW"
			label="Minimum FLOAT balance"
			name="minimum-balance"
			isValid={res.isValid()}
			errors={res.getErrors('minimum-balance')}
			bind:value={$eventGeneratorData.powerups.minimumBalance.data}
			on:input={handleChange}
		/>
	</div>
</PowerUpConfigWrapper>
