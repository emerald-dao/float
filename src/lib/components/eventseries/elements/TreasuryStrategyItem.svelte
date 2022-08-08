<script>
  import StrategyDisplay from "$lib/components/eventSeries/elements/StrategyDisplay.svelte";
  import { createEventDispatcher } from "svelte";
  import { user, eventSeries as seriesStore } from "$lib/flow/stores";

  /** @type {import('../types').EventSeriesData} */
  export let eventSeries;
  /**
   * @type {import('../types').StrategyDetail}
   */
  export let strategy;

  // dispatcher
  const dispatch = createEventDispatcher();

  const txInProgress = seriesStore.ClaimTreasuryRewards.InProgress;
  const txStatus = seriesStore.ClaimTreasuryRewards.Status;
</script>

<StrategyDisplay {strategy} />
