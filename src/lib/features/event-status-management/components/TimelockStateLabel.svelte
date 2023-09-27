<script lang="ts">
	import type { EventGeneralStatus } from '$lib/types/event/event.interface';
	import type { TimelockStatus } from '../types/verifiers-status.interface';
	import VerifierStateLabel from './atoms/VerifierStateLabel.svelte';

	export let timelockStatus: TimelockStatus;
	export let generalStatus: EventGeneralStatus;

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
		specificStatus={timelockStatus.status}
		icon="tabler:clock"
		{generalStatus}
		{message}
	/>
{/if}
