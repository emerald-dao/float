<script lang="ts">
	import { Currency } from '@emerald-dao/component-library';
	import PowerUpReviewCard from '../atoms/PowerUpCard.svelte';
	import { POWER_UPS } from '$lib/features/event-generator/components/steps/7-PowerUps/powerUps';

	export let balanceAmount: number;

	const minimumBalance = POWER_UPS['minimumBalance'];
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
