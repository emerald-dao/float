<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import { POWER_UPS, type PowerUpGeneratorData } from '../../../5-PowerUps/powerUps';
	import PowerUpReviewCard from '../atoms/PowerUpReviewCard.svelte';

	const paymentPowerUp = POWER_UPS.find(
		(powerUp) => powerUp.type === 'payment'
	) as PowerUpGeneratorData<'payment'>;

	const powerUpData = $eventGeneratorData.powerups.payment;
</script>

<PowerUpReviewCard name={paymentPowerUp.name} icon={paymentPowerUp.icon}>
	{powerUpData.data}
</PowerUpReviewCard>
