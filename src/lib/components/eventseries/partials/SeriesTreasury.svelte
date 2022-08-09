<script>
  import Loading from "$lib/components/common/Loading.svelte";
  import AchievementPoints from "../elements/AchievementPoints.svelte";
  import TreasuryStrategyItem from "../elements/TreasuryStrategyItem.svelte";
  import { createEventDispatcher } from "svelte";
  import { user, eventSeries as seriesStore } from "$lib/flow/stores";
  import {
    getSeriesStrategies,
    refreshUserStrategiesStatus,
  } from "$lib/flow/actions";

  /** @type {import('../types').EventSeriesData} */
  export let eventSeries;

  // dispatcher
  const dispatch = createEventDispatcher();

  $: preview = !$user?.addr;

  /** @type {Promise<import('../types').StrategyQueryResult>} */
  $: strategiesPromise = getSeriesStrategies(
    eventSeries.identifier.host,
    eventSeries.identifier.id,
    false,
    $user?.addr
  );

  const txInProgress = seriesStore.RefreshUserStatus.InProgress;
  const txStatus = seriesStore.RefreshUserStatus.Status;

  /**
   * @param {import('../types').StrategyQueryResult} data
   */
  function isNotSynced(data) {
    for (let i = 0; i < data.strategies.length; i++) {
      const strategy = data.strategies[i];
      let scoreEligible = false;
      if (strategy.strategyData.consumable) {
        scoreEligible =
          data.userConsumableScore > strategy.strategyData.threshold;
      } else {
        scoreEligible = data.userTotalScore > strategy.strategyData.threshold;
      }
      if (scoreEligible && !strategy.userStatus.eligible) {
        return true;
      }
    }
    return false;
  }

  function handleReset() {
    if ($txStatus?.success) {
      dispatch("seriesUpdated");
    }
    txInProgress.set(false);
    txStatus.set(false);
  }

  $: isValidToSubmit = true;

  function handleSubmit() {
    if (!isValidToSubmit) return;

    refreshUserStrategiesStatus(
      eventSeries.identifier.host,
      eventSeries.identifier.id
    );
  }
</script>

{#await strategiesPromise}
  <Loading />
{:then data}
  {#if !preview && data?.userTotalScore}
    <AchievementPoints
      totalScore={data?.userTotalScore}
      consumableScore={data?.userConsumableScore}
    />
    {#if isNotSynced(data)}
      {#if $txInProgress}
        <button aria-busy="true" disabled>
          Please wait for the transaction
        </button>
      {:else if $txStatus === false}
        <button
          on:click|preventDefault={handleSubmit}
          disabled={!isValidToSubmit}
        >
          Sync Status
        </button>
      {:else}
        {#if $txStatus.success}
          <p>Status synced successfully!</p>
        {:else if !$txStatus.success && $txStatus.error}
          <p>{JSON.stringify($txStatus.error)}</p>
        {/if}
        <button on:click|preventDefault={handleReset}> Continue </button>
      {/if}
    {/if}
  {/if}
  {#if data?.strategies?.length === 0}
    <div class="flex">There is no reward strategy for the FLOAT Series</div>
  {:else}
    <h4>Rewards</h4>
    {#each data.strategies as strategy}
      <TreasuryStrategyItem
        {strategy}
        {eventSeries}
        totalScore={data?.userTotalScore}
        consumableScore={data?.userConsumableScore}
        on:seriesUpdated={(e) => dispatch("seriesUpdated")}
      />
    {/each}
  {/if}
{/await}
