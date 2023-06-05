<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import { CurrencyInput } from '@emerald-dao/component-library';
	import PowerUpConfigWrapper from '../../atoms/PowerUpConfigWrapper.svelte';
	import POWER_UPS, { type PowerUp } from '../../powerUps';
	import type { SuiteRunResult } from 'vest';
	import validationSuite from './validation';

	const handleChange = () => {
		res = validationSuite($eventGeneratorData);

		(res as SuiteRunResult).done((result) => {
			res = result;
		});
	};

	let res = validationSuite.get();

	const powerUpData = POWER_UPS.find(
		(powerUp) => powerUp.type === 'minimumBalance'
	) as PowerUp<'minimumBalance'>;
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
