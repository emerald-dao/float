<script lang="ts">
	import PowerUpConfigWrapper from '../atoms/PowerUpConfigWrapper.svelte';
	import POWER_UPS from '../powerUps';

	const powerUpData = POWER_UPS.find((powerUp) => powerUp.type === 'secret-code');
</script>

<PowerUpConfigWrapper {powerUpData}>
	<div>
		<input type="text" />
	</div>
</PowerUpConfigWrapper>
