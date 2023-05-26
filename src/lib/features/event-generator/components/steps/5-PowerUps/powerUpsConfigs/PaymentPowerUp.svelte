<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import PowerUpConfigWrapper from '../atoms/PowerUpConfigWrapper.svelte';
	import POWER_UPS, { type PowerUp } from '../powerUps';
	import { CurrencyInput } from '@emerald-dao/component-library';

	const powerUpData = POWER_UPS.find((powerUp) => powerUp.type === 'payment') as PowerUp<'payment'>;
</script>

<PowerUpConfigWrapper {powerUpData}>
	<div>
		<CurrencyInput
			currency="FLOW"
			label="FLOAT price"
			bind:value={$eventGeneratorData.powerups.payment.data}
		/>
	</div>
</PowerUpConfigWrapper>
