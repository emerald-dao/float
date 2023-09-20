<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import { POWER_UPS, type PowerUpGeneratorData } from '../../../7-PowerUps/powerUps';
	import PowerUpReviewCard from '../atoms/PowerUpReviewCard.svelte';

	const paymentPowerUp = POWER_UPS.find(
		(powerUp) => powerUp.type === 'secretCode'
	) as PowerUpGeneratorData<'secretCode'>;

	const powerUpData = $eventGeneratorData.powerups.secretCode;
</script>

<PowerUpReviewCard name={paymentPowerUp.name} icon={paymentPowerUp.icon}>
	<span class="small">
		{powerUpData.data}
	</span>
</PowerUpReviewCard>
