<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import { InputWrapper } from '@emerald-dao/component-library';
	import PowerUpConfigWrapper from '../../atoms/PowerUpConfigWrapper.svelte';
	import { type PowerUpGeneratorData, POWER_UPS, powerUpsValidations } from '../../powerUps';
	import validationSuite from './validation';
	import type { SuiteRunResult } from 'vest';

	const powerUpData = POWER_UPS.find(
		(powerUp) => powerUp.type === 'limited'
	) as PowerUpGeneratorData<'limited'>;

	const handleChange = () => {
		res = validationSuite($eventGeneratorData);

		(res as SuiteRunResult).done((result) => {
			res = result;

			$powerUpsValidations.limited = res.isValid();
		});
	};

	let res = validationSuite.get();
</script>

<PowerUpConfigWrapper {powerUpData}>
	<div>
		<InputWrapper
			label="Amount of FLOATs"
			name="limited-amount"
			isValid={res.isValid()}
			errors={res.getErrors('limited-amount')}
		>
			<input
				type="number"
				name="limited-amount"
				bind:value={$eventGeneratorData.powerups.limited.data}
				on:input={handleChange}
			/>
		</InputWrapper>
	</div>
</PowerUpConfigWrapper>
