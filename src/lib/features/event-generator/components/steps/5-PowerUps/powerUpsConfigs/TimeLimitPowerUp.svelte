<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import PowerUpConfigWrapper from '../atoms/PowerUpConfigWrapper.svelte';
	import POWER_UPS, { type PowerUp } from '../powerUps';

	const powerUpData = POWER_UPS.find(
		(powerUp) => powerUp.type === 'timelock'
	) as PowerUp<'timelock'>;
</script>

<PowerUpConfigWrapper {powerUpData}>
	<div class="column-4">
		<div>
			<label for="start-date">Start date</label>
			<input
				type="date"
				name="start-date"
				bind:value={$eventGeneratorData.powerups.timelock.data.startDate}
			/>
		</div>
		<div>
			<label for="end-date">End date</label>
			<input
				type="date"
				name="end-date"
				bind:value={$eventGeneratorData.powerups.timelock.data.endDate}
			/>
		</div>
	</div>
</PowerUpConfigWrapper>
