<script lang="ts">
	import TimelockReview from './cards/TimelockReview.svelte';
	import MinimumBalanceReview from './cards/MinimumBalanceReview.svelte';
	import LimitedReview from './cards/LimitedReview.svelte';
	import PaymentReview from './cards/PaymentReview.svelte';
	import SecretCodeReview from './cards/SecretCodeReview.svelte';
	import type { EventVerifier } from '$lib/types/event/event.interface';

	export let powerUp: EventVerifier;
</script>

{#if powerUp.type === 'payment'}
	<PaymentReview />
{/if}

{#if powerUp.type === 'timelock'}
	<TimelockReview />
{/if}

{#if powerUp.type === 'secretCode'}
	<SecretCodeReview />
{/if}

{#if powerUp.type === 'limited'}
	<LimitedReview />
{/if}

{#if powerUp.type === 'minimumBalance'}
	<MinimumBalanceReview />
{/if}
