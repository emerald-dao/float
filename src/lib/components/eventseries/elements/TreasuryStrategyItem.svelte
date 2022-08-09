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
  const txKey = seriesStore.ClaimTreasuryRewards.Key;

  $: preview = !$user?.addr;
  $: progress = Math.min(
    100,
    Math.floor(
      (100 *
        (strategy.strategyData.consumable ? consumableScore : totalScore)) /
        strategy.strategyData.threshold
    )
  );
  $: isCurrentItem = $txKey === strategy.index;
  $: isValidToSubmit =
    strategy.currentState === "claimable" && strategy.userStatus.claimable;

  function handleReset() {
    if ($txStatus?.success) {
      dispatch("seriesUpdated");
    }
    txInProgress.set(false);
    txStatus.set(false);
    txKey.set(-1);
  }

  function handleSubmit() {
    if (!isValidToSubmit) return;

    txKey.set(strategy.index);
  }
</script>

<StrategyDisplay {strategy}>
  {#if !preview}
    <div class="panel-bg" style="width: {progress}%;" />
  {/if}

  <div slot="bottom" class="panel-bottom">
    {#if !preview}
      {#if $txInProgress && isCurrentItem}
        <button aria-busy="true" disabled>
          Please wait for the transaction
        </button>
      {:else if !isCurrentItem || $txStatus === false}
        {#if !isValidToSubmit}
          {#if strategy.userStatus.claimed}
            <button class="secondary outline" disabled>
              ✓ You already claimed this reward.
            </button>
          {:else if strategy.currentState === "opening" && !strategy.userStatus.eligible}
            <button disabled>
              You are not eligible, please obtain more POINTS.
            </button>
          {:else if strategy.currentState !== "claimable"}
            <button disabled> Please wait for the CLAIMABLE phase </button>
          {:else}
            <button class="secondary outline" disabled>
              You are not eligible or be a winner to claim the reward.
            </button>
          {/if}
        {:else}
          <button
            on:click|preventDefault={handleSubmit}
            disabled={!isValidToSubmit}
          >
            Claim Reward
          </button>
        {/if}
      {:else if isCurrentItem}
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
