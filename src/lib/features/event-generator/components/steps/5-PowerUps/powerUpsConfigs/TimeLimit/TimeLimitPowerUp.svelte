<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import { InputWrapper } from '@emerald-dao/component-library';
	import PowerUpConfigWrapper from '../../atoms/PowerUpConfigWrapper.svelte';
	import { type PowerUpGeneratorData, POWER_UPS, powerUpsValidations } from '../../powerUps';
	import validationSuite from './validation';
	import type { SuiteRunResult } from 'vest';
	import { onMount } from 'svelte';

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

	let startDate: string;
	let endDate: string;

	onMount(() => {
		if ($eventGeneratorData.powerups.timelock.data.startDate.length > 0) {
			startDate = new Date(Number($eventGeneratorData.powerups.timelock.data.startDate) * 1000)
				.toISOString()
				.split('T', 1)[0];
		}

		if ($eventGeneratorData.powerups.timelock.data.endDate.length > 0) {
			endDate = new Date(Number($eventGeneratorData.powerups.timelock.data.endDate) * 1000)
				.toISOString()
				.split('T', 1)[0];
		}
	});

	$: if (startDate) {
		$eventGeneratorData.powerups.timelock.data.startDate = Math.floor(
			new Date(startDate).getTime() / 1000
		).toString();
	}

	$: if (endDate) {
		$eventGeneratorData.powerups.timelock.data.endDate = Math.floor(
			new Date(endDate).getTime() / 1000
		).toString();
	}
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
					bind:value={startDate}
					on:input={handleChange}
				/>
			</InputWrapper>
			{$eventGeneratorData.powerups.timelock.data.startDate}
			{startDate}
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
					bind:value={endDate}
					on:input={handleChange}
				/>
			</InputWrapper>
		</div>
	</div>
</PowerUpConfigWrapper>
