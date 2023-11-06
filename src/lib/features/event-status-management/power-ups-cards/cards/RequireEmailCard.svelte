<script lang="ts">
	import PowerUpReviewCard from '../atoms/PowerUpCard.svelte';
	import { POWER_UPS } from '$lib/features/event-generator/components/steps/7-PowerUps/powerUps';

	const paymentPowerUp = POWER_UPS['requireEmail'];
</script>

<PowerUpReviewCard name={paymentPowerUp.name} icon={paymentPowerUp.icon} let:PowerUpCard>
	<PowerUpCard.Content>Required</PowerUpCard.Content>
</PowerUpReviewCard>
