<script>
  import Loading from "$lib/components/common/Loading.svelte";
  import { createEventDispatcher } from "svelte";
  import { user, eventSeries as seriesStore } from "$lib/flow/stores";
  import { getSeriesStrategies, addTreasuryStrategy } from "$lib/flow/actions";

  /** @type {import('../types').EventSeriesData} */
  export let eventSeries;

  // dispatcher
  const dispatch = createEventDispatcher();

  $: isValid = eventSeries.identifier.host === $user?.addr;

  /** @type {import('../types').AddStrategyRequest} */
  let requestParams;
  let strategiesPromise;

  const txInProgress = seriesStore.AddTreasuryStrategy.InProgress;
  const txStatus = seriesStore.AddTreasuryStrategy.Status;

  // init with false
  handleReset();

  function handleReset() {
    if ($txStatus?.success) {
      dispatch("seriesUpdated");
    }
    txInProgress.set(false);
    txStatus.set(false);

    requestParams = {
      seriesId: eventSeries.identifier.id,
      strategyMode: "queueStrategy",
      deliveryMode: "ftIdenticalAmount",
      options: {
        // with default value
        autoStart: true,
        consumable: false,
        // required to modify - strategy
        threshold: 0,
        maxClaimableShares: 1,
        // TODO: add time limit
        openingEnding: undefined,
        claimableEnding: undefined,
        // by strategy type
        minimiumValidAmount: undefined,
        // required to modify
        deliveryTokenIdentifier: null,
        // by delivery
        deliveryParam1: undefined,
      },
    };

    strategiesPromise = getSeriesStrategies(
      eventSeries.identifier.host,
      eventSeries.identifier.id,
      true
    );
  }

  $: isValidToSubmit = false;

  function handleSubmit() {
    if (!isValidToSubmit) return;

    addTreasuryStrategy(requestParams);
  }
</script>

{#if isValid}
  {#await strategiesPromise}
    <Loading />
  {:then data}
    <div class="no-break flex-col flex-gap mb-1">
      {JSON.stringify(data)}
    </div>
  {/await}
  <details>
    <summary role="button" class="secondary">
      <b>Add a new strategy →</b>
    </summary>

    <div class="grid no-break mb-1">
      <button
        class:secondary={requestParams.strategyMode !== "queueStrategy"}
        class="outline"
        on:click={() => {
          requestParams.strategyMode = "queueStrategy";
          requestParams.options.minimiumValidAmount = undefined;
        }}
      >
        Queue Strategy
        <span>
          Eligible users can claim reward one by one util all rewards claimed.
        </span>
      </button>
      <button
        class:secondary={requestParams.strategyMode !== "lotteryStrategy"}
        class="outline"
        on:click={() => {
          requestParams.strategyMode = "lotteryStrategy";
          requestParams.options.minimiumValidAmount = 0;
        }}
      >
        Lottery Strategy
        <span>
          Eligible users will get a ticket to join the raffle and only winners
          can claim rewards.
        </span>
      </button>
    </div>
    <div class="grid no-break mb-1">
      <button
        class:secondary={requestParams.deliveryMode !== "ftIdenticalAmount"}
        class="outline"
        on:click={() => {
          requestParams.deliveryMode = "ftIdenticalAmount";
          requestParams.options.deliveryTokenIdentifier = null;
          requestParams.options.deliveryParam1 = 0;
        }}
      >
        Identical Amount
        <span>
          Distribute <b>Fungible Token</b> with same amount for each claimer.
        </span>
      </button>
      <button
        class:secondary={requestParams.deliveryMode !== "ftRandomAmount"}
        class="outline"
        on:click={() => {
          requestParams.deliveryMode = "ftRandomAmount";
          requestParams.options.deliveryTokenIdentifier = null;
          requestParams.options.deliveryParam1 = 0;
        }}
      >
        Random Amount
        <span>
          Distribute <b>Fungible Token</b> with random amount within a total amount.
        </span>
      </button>
      <button
        class:secondary={requestParams.deliveryMode !== "nft"}
        class="outline"
        on:click={() => {
          requestParams.deliveryMode = "nft";
          requestParams.options.deliveryTokenIdentifier = null;
          requestParams.options.deliveryParam1 = undefined;
        }}
      >
        NFT
        <span>
          Distribute one share of <b>NFT</b> reward to each claimer.
        </span>
      </button>
    </div>

    <label for="threshold">
      <span class:highlight={requestParams.options.threshold > 0}>
        Achievement Points Eligible Threshold
      </span>
      <input
        type="number"
        id="threshold"
        name="threshold"
        min="1"
        max="10000000"
        placeholder="ex. 100"
        step="100"
        bind:value={requestParams.options.threshold}
      />
    </label>

    {#if $txInProgress}
      <button aria-busy="true" disabled>
        Please wait for the transaction
      </button>
    {:else if $txStatus === false}
      <button
        on:click|preventDefault={handleSubmit}
        disabled={!isValidToSubmit}
      >
        Add new Strategy
      </button>
    {:else}
      {#if $txStatus.success}
        <p>Strategy added successfully!</p>
      {:else if !$txStatus.success && $txStatus.error}
        <p>{JSON.stringify($txStatus.error)}</p>
      {/if}
      <button on:click|preventDefault={handleReset}> Continue </button>
    {/if}
  </details>
{/if}

<style>
  .outline {
    text-align: left;
  }

  .outline span {
    display: block;
    font-size: 0.75rem;
    line-height: 1.2;
    font-weight: 400;
    opacity: 0.6;
  }
</style>
