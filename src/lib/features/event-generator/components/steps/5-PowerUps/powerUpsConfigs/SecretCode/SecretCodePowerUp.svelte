<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import { InputWrapper } from '@emerald-dao/component-library';
	import PowerUpConfigWrapper from '../../atoms/PowerUpConfigWrapper.svelte';
	import { type PowerUpGeneratorData, POWER_UPS, powerUpsValidations } from '../../powerUps';
	import validationSuite from './validation';
	import type { SuiteRunResult } from 'vest';

	const powerUpData = POWER_UPS.find(
		(powerUp) => powerUp.type === 'secretCode'
	) as PowerUpGeneratorData<'secretCode'>;

	const handleChange = () => {
		res = validationSuite($eventGeneratorData);

		(res as SuiteRunResult).done((result) => {
			res = result;

			$powerUpsValidations.secretCode = res.isValid();
		});
	};

	let res = validationSuite.get();
</script>

<PowerUpConfigWrapper {powerUpData}>
	<div>
		<InputWrapper
			label="Secret code"
			name="secret-code"
			isValid={res.isValid()}
			errors={res.getErrors('secret-code')}
		>
			<input
				type="text"
				name="secret-code"
				bind:value={$eventGeneratorData.powerups.secretCode.data}
				on:input={handleChange}
			/>
		</InputWrapper>
	</div>
</PowerUpConfigWrapper>
