<script lang="ts">
	import type { TimelockStatus } from '../verifiers/types/verifiers-status.interface';
	import VerifierStateLabel from './atoms/VerifierStateLabel.svelte';

	export let timelockStatus: TimelockStatus;

	$: message =
		timelockStatus?.status === 'expired'
			? 'Expired'
			: timelockStatus?.status === 'unlocked'
			? `${timelockStatus?.remainingTime} time left`
			: `Unlocks in ${timelockStatus?.remainingTime} days`;
</script>

{#if timelockStatus !== null}
	<VerifierStateLabel
		name="Timelock"
		status={timelockStatus.status}
		icon="tabler:clock"
		{message}
	/>
{/if}
