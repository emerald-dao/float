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
		(powerUp) => powerUp.type === 'timelock'
	) as PowerUp<'timelock'>;
</script>

<PowerUpConfigWrapper {powerUpData}>
	<div class="column-4">
		<div>
			<InputWrapper
				label="Start date"
				name="start-date"
				isValid={res.isValid('start-date')}
				errors={res.getErrors('start-date')}
			>
				<input
					type="date"
					name="start-date"
					bind:value={$eventGeneratorData.powerups.timelock.data.startDate}
					on:input={handleChange}
				/>
			</InputWrapper>
			{$eventGeneratorData.powerups.timelock.data.startDate}
		</div>
		<div>
			<InputWrapper
				label="End date"
				name="end-date"
				isValid={res.isValid('end-date')}
				errors={res.getErrors('end-date')}
			>
				<input
					type="date"
					name="end-date"
					bind:value={$eventGeneratorData.powerups.timelock.data.endDate}
					on:input={handleChange}
				/>
			</InputWrapper>
		</div>
	</div>
</PowerUpConfigWrapper>
