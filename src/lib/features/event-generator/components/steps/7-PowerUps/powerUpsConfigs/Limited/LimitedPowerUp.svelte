<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import { InputWrapper } from '@emerald-dao/component-library';
	import PowerUpConfigWrapper from '../../atoms/PowerUpConfigWrapper.svelte';
	import { POWER_UPS, powerUpsValidations } from '../../powerUps';
	import validationSuite from './validation';
	import type { SuiteRunResult } from 'vest';

	const powerUpData = POWER_UPS['limited'];

	$: isActive = $eventGeneratorData.powerups.limited.active;

	const handleChange = () => {
		res = validationSuite($eventGeneratorData);

		(res as SuiteRunResult).done((result) => {
			res = result;

			$powerUpsValidations.limited = res.isValid();
		});
	};

	let res = validationSuite.get();
</script>

<PowerUpConfigWrapper {powerUpData} powerUpType="limited">
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
				disabled={!isActive}
				bind:value={$eventGeneratorData.powerups.limited.data}
				on:input={handleChange}
			/>
		</InputWrapper>
	</div>
</PowerUpConfigWrapper>
