<script lang="ts">
	import type { LimitedStatus } from '../verifiers/types/verifiers-status.interface';
	import VerifierStateLabel from './atoms/VerifierStateLabel.svelte';

	export let limitedStatus: LimitedStatus;

	$: message =
		limitedStatus?.status === 'soldout' ? 'Sold out' : `${limitedStatus?.remainingFloats} left`;
</script>

{#if limitedStatus !== null}
	<VerifierStateLabel name="Supply" status={limitedStatus.status} icon="tabler:ticket" {message} />
{/if}
