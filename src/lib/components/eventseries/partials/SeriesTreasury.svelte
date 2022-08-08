<script>
  import Loading from "$lib/components/common/Loading.svelte";
  import AchievementPoints from "$lib/components/eventSeries/elements/AchievementPoints.svelte";
  import TreasuryStrategyItem from "$lib/components/eventSeries/elements/TreasuryStrategyItem.svelte";
  import { createEventDispatcher } from "svelte";
  import { user, eventSeries as seriesStore } from "$lib/flow/stores";
  import { getSeriesStrategies } from "$lib/flow/actions";

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
</script>

{#await strategiesPromise}
  <Loading />
{:then data}
  {#if !preview && data?.userTotalScore}
    <AchievementPoints
      totalScore={data?.userTotalScore}
      consumableScore={data?.userConsumableScore}
    />
  {/if}
  {#if data?.strategies?.length === 0}
    <div class="flex">There is no reward strategy for the FLOAT Series</div>
  {:else}
    <h4>Rewards</h4>
    {#each data.strategies as strategy}
      <TreasuryStrategyItem
        {strategy}
        {eventSeries}
        on:seriesUpdated={(e) => dispatch("seriesUpdated")}
      />
    {/each}
  {/if}
{/await}
