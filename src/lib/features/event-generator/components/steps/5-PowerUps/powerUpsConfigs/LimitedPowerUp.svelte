<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import PowerUpConfigWrapper from '../atoms/PowerUpConfigWrapper.svelte';
	import POWER_UPS, { type PowerUp } from '../powerUps';

	const powerUpData = POWER_UPS.find((powerUp) => powerUp.type === 'limited') as PowerUp<'limited'>;
</script>

<PowerUpConfigWrapper {powerUpData}>
	<div>
		<label for="limited">Amount of FLOATs</label>
		<input type="number" name="limited" bind:value={$eventGeneratorData.powerups.limited.data} />
	</div>
</PowerUpConfigWrapper>
