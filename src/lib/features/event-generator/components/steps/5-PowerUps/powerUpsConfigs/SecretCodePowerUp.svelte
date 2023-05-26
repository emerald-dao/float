<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import PowerUpConfigWrapper from '../atoms/PowerUpConfigWrapper.svelte';
	import POWER_UPS, { type PowerUp } from '../powerUps';

	const powerUpData = POWER_UPS.find(
		(powerUp) => powerUp.type === 'secretCode'
	) as PowerUp<'secretCode'>;
</script>

<PowerUpConfigWrapper {powerUpData}>
	<div>
		<label for="secret-code">Secret code</label>
		<input
			type="text"
			name="secret-code"
			bind:value={$eventGeneratorData.powerups.secretCode.data}
		/>
	</div>
</PowerUpConfigWrapper>
