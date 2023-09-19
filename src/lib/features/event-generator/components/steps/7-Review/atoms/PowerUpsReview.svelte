<script lang="ts">
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
	import LimitedCard from '$lib/features/event-status-management/power-ups-cards/cards/LimitedCard.svelte';
	import MinimumBalanceCard from '$lib/features/event-status-management/power-ups-cards/cards/MinimumBalanceCard.svelte';
	import PaymentCard from '$lib/features/event-status-management/power-ups-cards/cards/PaymentCard.svelte';
	import SecretCodeCard from '$lib/features/event-status-management/power-ups-cards/cards/SecretCodeCard.svelte';
	import TimelockCard from '$lib/features/event-status-management/power-ups-cards/cards/TimelockCard.svelte';
</script>

<div class="powerups-cards-wrapper">
	{#if $eventGeneratorData.powerups.timelock.active}
		<TimelockCard
			startDate={$eventGeneratorData.powerups.timelock.data.dateStart}
			endDate={$eventGeneratorData.powerups.timelock.data.dateEnding}
		/>
	{/if}
	{#if $eventGeneratorData.powerups.limited.active}
		<LimitedCard maxSupply={Number($eventGeneratorData.powerups.limited.data)} claims={null} />
	{/if}
	{#if $eventGeneratorData.powerups.minimumBalance.active}
		<MinimumBalanceCard balanceAmount={Number($eventGeneratorData.powerups.minimumBalance.data)} />
	{/if}
	{#if $eventGeneratorData.powerups.secret.active}
		<SecretCodeCard secretCode={$eventGeneratorData.powerups.secret.data} isAdmin={true} />
	{/if}
	{#if $eventGeneratorData.powerups.payment.active && Number($eventGeneratorData.powerups.payment.data) > 0}
		<PaymentCard price={$eventGeneratorData.powerups.payment.data.toString()} />
	{/if}
</div>

<style lang="scss">
	.powerups-cards-wrapper {
		display: flex;
		flex-direction: row;
		gap: var(--space-3);
		flex-wrap: wrap;
		align-items: flex-start;
	}
</style>
