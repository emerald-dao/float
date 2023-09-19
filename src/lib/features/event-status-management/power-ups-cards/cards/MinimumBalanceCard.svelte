<script lang="ts">
	import { Currency } from '@emerald-dao/component-library';
	import PowerUpReviewCard from '../atoms/PowerUpCard.svelte';
	import {
		POWER_UPS,
		type PowerUpGeneratorData
	} from '$lib/features/event-generator/components/steps/6-PowerUps/powerUps';

	export let balanceAmount: number;

	const minimumBalance = POWER_UPS.find(
		(powerUp) => powerUp.type === 'minimumBalance'
	) as PowerUpGeneratorData<'minimumBalance'>;
</script>

<PowerUpReviewCard name={minimumBalance.name} icon={minimumBalance.icon} let:PowerUpCard>
	<PowerUpCard.Content>
		<Currency
			amount={balanceAmount}
			currency="FLOW"
			fontSize="var(--font-size-0)"
			thinCurrency={false}
		/>
	</PowerUpCard.Content>
</PowerUpReviewCard>
