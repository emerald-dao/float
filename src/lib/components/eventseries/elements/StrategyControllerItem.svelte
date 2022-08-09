<script>
  import StrategyDisplay from "./StrategyDisplay.svelte";
  import { createEventDispatcher } from "svelte";
  import { user, eventSeries as seriesStore } from "$lib/flow/stores";
  import { nextTreasuryStrategyStage } from "$lib/flow/actions";

  /** @type {import('../types').EventSeriesData} */
  export let eventSeries;
  /**
   * @type {import('../types').StrategyDetail}
   */
  export let strategy;

  // dispatcher
  const dispatch = createEventDispatcher();

  const txInProgress = seriesStore.NextTreasuryStrategyStage.InProgress;
  const txStatus = seriesStore.NextTreasuryStrategyStage.Status;

  $: isValidAdmin = eventSeries.identifier.host === $user?.addr;
  $: isValidToSubmit =
    strategy.currentState !== "closed" &&
    (strategy.currentState === "opening" &&
    strategy.strategyMode === "raffleStrategy"
      ? strategy.strategyData.minValid <= strategy.strategyData.valid.length
      : true);
  $: nextStage = {
    preparing: "opening",
    opening: "claimable",
    claimable: "closed",
  }[strategy.currentState];

  function handleReset() {
    if ($txStatus?.success) {
      dispatch("seriesUpdated");
    }
    txInProgress.set(false);
    txStatus.set(false);
  }

  function handleSubmit() {
    if (!isValidToSubmit) return;

    nextTreasuryStrategyStage(eventSeries.identifier.id, strategy.index);
  }
</script>

<StrategyDisplay {strategy}>
  <div slot="bottom" class="panel-bottom">
    {#if isValidAdmin}
      {#if $txInProgress}
        <button aria-busy="true" disabled>
          Please wait for the transaction
        </button>
      {:else if $txStatus === false}
        {#if isValidToSubmit}
          <button
            on:click|preventDefault={handleSubmit}
            disabled={!isValidToSubmit}
          >
            Set to {String(nextStage).toUpperCase()}
          </button>
        {:else}
          <button disabled>Need more eligible users</button>
        {/if}
      {:else}
        {#if $txStatus.success}
          <p>Transaction executed successfully!</p>
        {:else if !$txStatus.success && $txStatus.error}
          <p>{JSON.stringify($txStatus.error)}</p>
        {/if}
        <button on:click|preventDefault={handleReset}> Continue </button>
      {/if}
    {/if}
  </div>
</StrategyDisplay>
