<script>
  import StrategyDisplay from "./StrategyDisplay.svelte";
  import { createEventDispatcher } from "svelte";
  import { user, eventSeries as seriesStore } from "$lib/flow/stores";

  /** @type {import('../types').EventSeriesData} */
  export let eventSeries;
  /**
   * @type {import('../types').StrategyDetail}
   */
  export let strategy;
  export let totalScore = undefined;
  export let consumableScore = undefined;

  // dispatcher
  const dispatch = createEventDispatcher();

  const txInProgress = seriesStore.ClaimTreasuryRewards.InProgress;
  const txStatus = seriesStore.ClaimTreasuryRewards.Status;

  $: preview = !$user?.addr;
  $: progress = Math.min(
    100,
    Math.floor(
      (100 *
        (strategy.strategyData.consumable ? consumableScore : totalScore)) /
        strategy.strategyData.threshold
    )
  );
  $: isValidToSubmit =
    strategy.currentState === "claimable" && strategy.userStatus.claimable;

  function handleReset() {
    if ($txStatus?.success) {
      dispatch("seriesUpdated");
    }
    txInProgress.set(false);
    txStatus.set(false);
  }

  function handleSubmit() {
    if (!isValidToSubmit) return;

    // TODO
  }
</script>

<StrategyDisplay {strategy}>
  {#if !preview}
    <div class="panel-bg" style="left: {progress - 100}%;" />

    {#if $txInProgress}
      <button aria-busy="true" disabled>
        Please wait for the transaction
      </button>
    {:else if $txStatus === false}
      {#if !isValidToSubmit}
        <button disabled>
          {#if strategy.currentState !== "claimable"}
            Please wait for claimable
          {:else}
            You are not eligible to claim the reward.
          {/if}
        </button>
      {:else}
        <button
          on:click|preventDefault={handleSubmit}
          disabled={!isValidToSubmit}
        >
          Claim Reward
        </button>
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
</StrategyDisplay>
