<script lang="ts">
	import type { EventGeneralStatus } from '$lib/types/event/event.interface';
	import type { LimitedStatus } from '../types/verifiers-status.interface';
	import VerifierStateLabel from './atoms/VerifierStateLabel.svelte';

	export let limitedStatus: LimitedStatus;
	export let generalStatus: EventGeneralStatus;

	$: message =
		limitedStatus?.status === 'soldout' ? 'Sold out' : `${limitedStatus?.remainingFloats} left`;
</script>

{#if limitedStatus !== null}
	<VerifierStateLabel
		name="Supply"
		specificStatus={limitedStatus.status}
		icon="tabler:ticket"
		{message}
		{generalStatus}
	/>
{/if}
