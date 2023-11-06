<script lang="ts">
	import TimelockCard from './cards/TimelockCard.svelte';
	import MinimumBalanceCard from './cards/MinimumBalanceCard.svelte';
	import LimitedCard from './cards/LimitedCard.svelte';
	import PaymentCard from './cards/PaymentCard.svelte';
	import SecretCodeCard from './cards/SecretCodeCard.svelte';
	import type { EventVerifiers } from '$lib/types/event/event.interface';
	import RequireEmailCard from './cards/RequireEmailCard.svelte';

	export let powerUps: EventVerifiers;
	export let price: string | null = null;
	export let numberOfClaims: number | null = null;
	export let isAdmin = false;
</script>

<div class="powerups-cards-wrapper">
	{#if powerUps.timelock}
		<TimelockCard startDate={powerUps.timelock.dateStart} endDate={powerUps.timelock.dateEnding} />
	{/if}
	{#if powerUps.limited}
		<LimitedCard maxSupply={Number(powerUps.limited.capacity)} claims={numberOfClaims} />
	{/if}
	{#if powerUps.minimumBalance}
		<MinimumBalanceCard balanceAmount={Number(powerUps.minimumBalance.amount)} />
	{/if}
	{#if powerUps.secret}
		<SecretCodeCard secretCode={powerUps.secret.publicKey} {isAdmin} />
	{/if}
	{#if price && Number(price) > 0}
		<PaymentCard {price} />
	{/if}
	{#if powerUps.requireEmail}
		<RequireEmailCard />
	{/if}
</div>

<style lang="scss">
	.powerups-cards-wrapper {
		display: flex;
		flex-direction: row;
		gap: var(--space-4);
		flex-wrap: wrap;
	}
</style>
