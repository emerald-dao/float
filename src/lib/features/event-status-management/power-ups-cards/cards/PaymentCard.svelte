<script lang="ts">
	import { Currency } from '@emerald-dao/component-library';
	import PowerUpReviewCard from '../atoms/PowerUpCard.svelte';
	import { POWER_UPS } from '$lib/features/event-generator/components/steps/7-PowerUps/powerUps';

	export let price: string;

	const paymentPowerUp = POWER_UPS['payment'];
</script>

<PowerUpReviewCard name={paymentPowerUp.name} icon={paymentPowerUp.icon} let:PowerUpCard>
	<PowerUpCard.Content>
		<Currency amount={price} currency="FLOW" fontSize="var(--font-size-0)" thinCurrency={false} />
	</PowerUpCard.Content>
</PowerUpReviewCard>
