<script lang="ts">
	import { CurrencyInput } from '@emerald-dao/component-library';
	import PowerUpConfigWrapper from '../atoms/PowerUpConfigWrapper.svelte';
	import POWER_UPS, { type PowerUp } from '../powerUps';

	const powerUpData = POWER_UPS.find((powerUp) => powerUp.type === 'minimum-balance') as PowerUp;
</script>

<PowerUpConfigWrapper {powerUpData}>
	<div>
		<CurrencyInput currency="FLOW" label="Minimum wallet balance" />
	</div>
</PowerUpConfigWrapper>
