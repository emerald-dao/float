<script lang="ts">
	import PowerUpConfigWrapper from '../atoms/PowerUpConfigWrapper.svelte';
	import POWER_UPS from '../powerUps';

	// get 'paymemt' power up
	const paymentPowerUp = POWER_UPS.find((powerUp) => powerUp.type === 'payment');
</script>

<PowerUpConfigWrapper powerUpData={paymentPowerUp}>
	<div>
		<input type="text" />
	</div>
</PowerUpConfigWrapper>
