<script lang="ts">
	import PowerUpConfigWrapper from '../atoms/PowerUpConfigWrapper.svelte';
	import POWER_UPS, { type PowerUp } from '../powerUps';

	const powerUpData = POWER_UPS.find((powerUp) => powerUp.type === 'limited') as PowerUp;
</script>

<PowerUpConfigWrapper {powerUpData}>
	<div>
		<label for="limited">Amount of FLOATs</label>
		<input type="number" name="limited" />
	</div>
</PowerUpConfigWrapper>
