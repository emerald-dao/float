<script>
  import { t } from "svelte-i18n";
  import StrategyDisplay from "./StrategyDisplay.svelte";
  import { createEventDispatcher } from "svelte";
  import { user, eventSeries as seriesStore } from "$lib/flow/stores";
  import { nextTreasuryStrategyStage } from "$lib/flow/actions";
  import Button from "$lib/components/landing/Button.svelte";

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
  const txKey = seriesStore.NextTreasuryStrategyStage.Key;

  $: isCurrentItem = $txKey === strategy.index;
  $: isValidAdmin = eventSeries.identifier.host === $user?.addr;
  $: isValidToSubmit =
    strategy.currentState !== "closed" &&
    (strategy.currentState === "pending" &&
    strategy.strategyMode === "raffleStrategy"
      ? strategy.strategyData.minValid <= strategy.strategyData.valid.length
      : true);
  $: nextStage = {
    preparing: "pending",
    pending: "claimable",
    claimable: "closed",
  }[strategy.currentState];

  function handleReset() {
    if ($txStatus?.success) {
      dispatch("seriesUpdated");
    }
    txInProgress.set(false);
    txStatus.set(false);
    txKey.set(-1);
  }

  function handleSubmit(forceClose) {
    txKey.set(strategy.index);

    nextTreasuryStrategyStage(
      eventSeries.identifier.id,
      strategy.index,
      forceClose
    );
  }
</script>

<StrategyDisplay {strategy}>
  <div slot="bottom" class="panel-bottom">
    {#if isValidAdmin}
      {#if $txInProgress && isCurrentItem}
        <button aria-busy="true" disabled>
          {$t("common.hint.please-wait-for-tx")}
        </button>
      {:else if !isCurrentItem || $txStatus === false}
        <div class="flex-wrap flex-gap">
          {#if isValidToSubmit}
            <button
              class:part-one={strategy.currentState !== "claimable"}
              on:click|preventDefault={(e) => handleSubmit(false)}
              disabled={!isValidToSubmit}
            >
              {$t("challenges.elements.strategy.set-state", {
                values: { state: String(nextStage).toUpperCase() },
              })}
            </button>
          {:else}
            <button
              class:part-one={strategy.currentState !== "claimable"}
              disabled
            >
              {$t("challenges.elements.strategy.no-more-eligible")}
            </button>
          {/if}
          {#if strategy.currentState !== "claimable"}
            <button
              class="outline red part-two"
              on:click|preventDefault={(e) => handleSubmit(true)}
            >
              {$t("challenges.elements.strategy.fore-close")}
            </button>
          {/if}
        </div>
      {:else if isCurrentItem}
        {#if $txStatus.success}
          <p>
            {$t("common.hint.tx-successful")}
          </p>
        {:else if !$txStatus.success && $txStatus.error}
          <p>{JSON.stringify($txStatus.error)}</p>
        {/if}
        <button on:click|preventDefault={handleReset}>
          {$t("common.btn.continue")}
        </button>
      {/if}
    {/if}
  </div>
</StrategyDisplay>

<style>
  button.part-one {
    width: 72%;
  }
  button.part-two {
    width: 22%;
  }
</style>
