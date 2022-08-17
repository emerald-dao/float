<script>
  import { t } from "svelte-i18n";
  import Loading from "$lib/components/common/Loading.svelte";
  import AchievementPoints from "../elements/AchievementPoints.svelte";
  import TreasuryStrategyItem from "../elements/TreasuryStrategyItem.svelte";
  import EventCertificateItem from "../elements/EventCertificateItem.svelte";
  import { createEventDispatcher } from "svelte";
  import { user, eventSeries as seriesStore } from "$lib/flow/stores";
  import {
    getSeriesStrategies,
    refreshUserStrategiesStatus,
    ownsSpecificFloatsAll,
  } from "$lib/flow/actions";

  /** @type {import('../types').EventSeriesData} */
  export let eventSeries;

  // dispatcher
  const dispatch = createEventDispatcher();

  $: preview = !$user?.addr;

  $: certificates = Object.values(eventSeries.extra?.Certificates ?? {});

  /** @type {Promise<import('../types').StrategyQueryResult>} */
  $: strategiesPromise = getSeriesStrategies(
    eventSeries.identifier.host,
    eventSeries.identifier.id,
    false,
    $user?.addr
  );

  const txInProgress = seriesStore.RefreshUserStatus.InProgress;
  const txStatus = seriesStore.RefreshUserStatus.Status;

  async function queryOwnsStatus() {
    if (preview || certificates.length === 0) return [];

    return await ownsSpecificFloatsAll(
      $user?.addr,
      certificates.map((one) => one.eventId)
    );
  }

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
          {$t("common.hint.please-wait-for-tx")}
        </button>
      {:else if $txStatus === false}
        <button
          on:click|preventDefault={handleSubmit}
          disabled={!isValidToSubmit}
        >
          {$t("challenges.detail.treasury.btn-sync-status")}
        </button>
      {:else}
        {#if $txStatus.success}
          <p>{$t("common.hint.tx-successful")}</p>
        {:else if !$txStatus.success && $txStatus.error}
          <p>{JSON.stringify($txStatus.error)}</p>
        {/if}
        <button on:click|preventDefault={handleReset}>
          {$t("common.btn.continue")}
        </button>
      {/if}
    {/if}
  {/if}

  {#if certificates.length > 0}
    <h4>{$t("challenges.detail.main.title-certificate")}</h4>
    {#await queryOwnsStatus() then ownsStatus}
      <div class="flex-wrap flex-gap mb-1">
        {#each certificates as one, index (one ? `${one.host}#${one.eventId}@${index}` : "emptySlot#" + index)}
          <EventCertificateItem
            event={one}
            points={undefined}
            {preview}
            owned={ownsStatus[index]}
          />
        {/each}
      </div>
    {/await}
  {/if}

  {#if !data?.strategies?.length}
    <div class="flex">{$t("errors.challenges.no-reward-strategy")}</div>
  {:else}
    <h4>
      {$t("challenges.detail.main.title-rewards")}
    </h4>
    {#each data?.strategies as strategy}
      <TreasuryStrategyItem
        {strategy}
        {eventSeries}
        totalScore={data?.userTotalScore}
        consumableScore={data?.userConsumableScore}
        on:seriesUpdated={function () {
          dispatch("seriesUpdated");
        }}
      />
    {/each}
  {/if}
{/await}
