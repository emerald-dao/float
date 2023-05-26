<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import { InputWrapper } from '@emerald-dao/component-library';
	import PowerUpConfigWrapper from '../../atoms/PowerUpConfigWrapper.svelte';
	import POWER_UPS, { type PowerUp } from '../../powerUps';
	import validationSuite from './validation';
	import type { SuiteRunResult } from 'vest';

	const handleChange = () => {
		res = validationSuite($eventGeneratorData);

		(res as SuiteRunResult).done((result) => {
			res = result;
		});
	};

	let res = validationSuite.get();

	const powerUpData = POWER_UPS.find(
		(powerUp) => powerUp.type === 'secretCode'
	) as PowerUp<'secretCode'>;
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
