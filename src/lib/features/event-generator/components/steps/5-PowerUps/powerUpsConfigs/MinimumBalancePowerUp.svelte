<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import { CurrencyInput } from '@emerald-dao/component-library';
	import PowerUpConfigWrapper from '../atoms/PowerUpConfigWrapper.svelte';
	import POWER_UPS, { type PowerUp } from '../powerUps';

	const powerUpData = POWER_UPS.find(
		(powerUp) => powerUp.type === 'minimumBalance'
	) as PowerUp<'minimumBalance'>;
</script>

<PowerUpConfigWrapper {powerUpData}>
	<div>
		<CurrencyInput
			currency="FLOW"
			label="Minimum wallet balance"
			bind:value={$eventGeneratorData.powerups.minimumBalance.data}
		/>
	</div>
</PowerUpConfigWrapper>
