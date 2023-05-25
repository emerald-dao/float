<script lang="ts">
	import PowerUpConfigWrapper from '../atoms/PowerUpConfigWrapper.svelte';
	import POWER_UPS, { type PowerUp } from '../powerUps';

	const powerUpData = POWER_UPS.find((powerUp) => powerUp.type === 'secret-code') as PowerUp;
</script>

<PowerUpConfigWrapper {powerUpData}>
	<div>
		<label for="secret-code">Secret code</label>
		<input type="text" name="secret-code" />
	</div>
</PowerUpConfigWrapper>
