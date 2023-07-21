<script lang="ts">
	import TimelockReview from './cards/TimelockReview.svelte';
	import MinimumBalanceReview from './cards/MinimumBalanceReview.svelte';
	import LimitedReview from './cards/LimitedReview.svelte';
	import PaymentReview from './cards/PaymentReview.svelte';
	import SecretCodeReview from './cards/SecretCodeReview.svelte';
	import { eventGeneratorData } from '$lib/features/event-generator/stores/EventGeneratorData';
</script>

{#if $eventGeneratorData.powerups.payment.active}
	<PaymentReview />
{/if}

{#if $eventGeneratorData.powerups.timelock.active}
	<TimelockReview />
{/if}

{#if $eventGeneratorData.powerups.secretCode.active}
	<SecretCodeReview />
{/if}

{#if $eventGeneratorData.powerups.limited.active}
	<LimitedReview />
{/if}

{#if $eventGeneratorData.powerups.minimumBalance.active}
	<MinimumBalanceReview />
{/if}
