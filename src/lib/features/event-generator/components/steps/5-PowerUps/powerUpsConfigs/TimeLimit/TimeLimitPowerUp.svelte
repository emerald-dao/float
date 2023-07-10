<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import { InputWrapper } from '@emerald-dao/component-library';
	import PowerUpConfigWrapper from '../../atoms/PowerUpConfigWrapper.svelte';
	import { type PowerUpGeneratorData, POWER_UPS, powerUpsValidations } from '../../powerUps';
	import validationSuite from './validation';
	import type { SuiteRunResult } from 'vest';

	const powerUpData = POWER_UPS.find(
		(powerUp) => powerUp.type === 'timelock'
	) as PowerUpGeneratorData<'timelock'>;

	$: isActive = $eventGeneratorData.powerups.timelock.active;

	const handleChange = () => {
		res = validationSuite($eventGeneratorData);

		(res as SuiteRunResult).done((result) => {
			res = result;

			$powerUpsValidations.timelock = res.isValid();
		});
	};

	let res = validationSuite.get();
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
					disabled={!isActive}
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
					disabled={!isActive}
					bind:value={$eventGeneratorData.powerups.timelock.data.endDate}
					on:input={handleChange}
				/>
			</InputWrapper>
		</div>
	</div>
</PowerUpConfigWrapper>
