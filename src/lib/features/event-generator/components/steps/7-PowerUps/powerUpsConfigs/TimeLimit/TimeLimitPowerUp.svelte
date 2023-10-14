<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import { InputWrapper } from '@emerald-dao/component-library';
	import PowerUpConfigWrapper from '../../atoms/PowerUpConfigWrapper.svelte';
	import { POWER_UPS, powerUpsValidations } from '../../powerUps';
	import validationSuite from './validation';
	import type { SuiteRunResult } from 'vest';
	import { onMount } from 'svelte';

	const powerUpData = POWER_UPS['timelock'];

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
		if ($eventGeneratorData.powerups.timelock.data.dateStart.length > 0) {
			startDate = new Date(Number($eventGeneratorData.powerups.timelock.data.dateStart) * 1000)
				.toISOString()
				.split('T', 1)[0];
		}

		if ($eventGeneratorData.powerups.timelock.data.dateEnding.length > 0) {
			endDate = new Date(Number($eventGeneratorData.powerups.timelock.data.dateEnding) * 1000)
				.toISOString()
				.split('T', 1)[0];
		}
	});

	$: if (startDate) {
		$eventGeneratorData.powerups.timelock.data.dateStart = Math.floor(
			new Date(startDate).getTime() / 1000
		).toString();
	}

	$: if (endDate) {
		$eventGeneratorData.powerups.timelock.data.dateEnding = Math.floor(
			new Date(endDate).getTime() / 1000
		).toString();
	}
</script>

<PowerUpConfigWrapper {powerUpData} powerUpType="timelock">
	<div class="column-4">
		<div>
			<InputWrapper
				label="Start date"
				name="start-date"
				isValid={res.isValid('start-date')}
				errors={res.getErrors('start-date')}
			>
				<input
					type="datetime-local"
					name="start-date"
					disabled={!isActive}
					bind:value={startDate}
					on:input={handleChange}
				/>
			</InputWrapper>
		</div>
		<div>
			<InputWrapper
				label="End date"
				name="end-date"
				isValid={res.isValid('end-date')}
				errors={res.getErrors('end-date')}
			>
				<input
					type="datetime-local"
					name="end-date"
					disabled={!isActive}
					bind:value={endDate}
					on:input={handleChange}
				/>
			</InputWrapper>
		</div>
	</div>
</PowerUpConfigWrapper>
