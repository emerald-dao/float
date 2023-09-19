<script lang="ts">
	import PowerUpState from '../atoms/PowerUpCardState.svelte';
	import PowerUpReviewCard from '../atoms/PowerUpCard.svelte';
	import {
		POWER_UPS,
		type PowerUpGeneratorData
	} from '$lib/features/event-generator/components/steps/6-PowerUps/powerUps';
	import { limitedToStatusObject } from '../../functions/helpers/limitedToStatusObject';

	export let maxSupply: number;
	export let claims: number | null;

	const limitedStatus = claims ? limitedToStatusObject(maxSupply, claims) : null;

	const limitedPowerUp = POWER_UPS['limited'];

	$: message =
		limitedStatus?.status === 'soldout' ? 'Sold out' : `${limitedStatus?.remainingFloats} left`;
</script>

<PowerUpReviewCard name={limitedPowerUp.name} icon={limitedPowerUp.icon} let:PowerUpCard>
	<PowerUpCard.Content>
		<PowerUpCard.Details>
			{maxSupply} NFTs
		</PowerUpCard.Details>
	</PowerUpCard.Content>
	{#if limitedStatus !== null}
		<PowerUpState status="active" {message} />
	{/if}
</PowerUpReviewCard>
