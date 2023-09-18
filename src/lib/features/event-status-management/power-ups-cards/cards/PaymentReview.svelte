<script lang="ts">
	import { Currency } from '@emerald-dao/component-library';
	import PowerUpReviewCard from '../atoms/PowerUpCard.svelte';
	import {
		POWER_UPS,
		type PowerUpGeneratorData
	} from '$lib/features/event-generator/components/steps/6-PowerUps/powerUps';

	export let price: string;

	const paymentPowerUp = POWER_UPS.find(
		(powerUp) => powerUp.type === 'payment'
	) as PowerUpGeneratorData<'payment'>;
</script>

<PowerUpReviewCard name={paymentPowerUp.name} icon={paymentPowerUp.icon} let:PowerUpCard>
	<PowerUpCard.Content>
		<Currency amount={price} currency="FLOW" fontSize="var(--font-size-0)" />
	</PowerUpCard.Content>
</PowerUpReviewCard>
