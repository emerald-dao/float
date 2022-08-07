<script>
  import Loading from "$lib/components/common/Loading.svelte";
  import FTlist from "$lib/components/common/FTlist.svelte";
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
  /** @type {Promise<import('../types').StrategyData>} */
  let strategiesPromise;
  /** @type {import('flow-native-token-registry').TokenInfo & {balance: number}} */
  let currentToken;

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
        minimumValidAmount: undefined,
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

  /**
   * @param {import('flow-native-token-registry').TokenInfo} token
   */
  function setCurrentToken(token) {
    if (token) {
      currentToken = token;
      requestParams.options.deliveryTokenIdentifier = `A.${token.address.slice(
        2
      )}.${token.contractName}.Vault`;
    } else {
      currentToken = null;
      requestParams.options.deliveryTokenIdentifier = null;
    }
  }

  $: isValidToSubmit =
    requestParams.options?.threshold > 0 &&
    requestParams.options?.maxClaimableShares > 0 &&
    typeof requestParams.options?.deliveryTokenIdentifier === "string" &&
    (requestParams.deliveryMode !== "nft"
      ? requestParams.options.deliveryParam1 > 0
      : true) &&
    (requestParams.strategyMode === "lotteryStrategy"
      ? requestParams.options.minimumValidAmount > 0
      : true);

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
            requestParams.options.minimumValidAmount = undefined;
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
            requestParams.options.minimumValidAmount = 0;
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
            if (requestParams.deliveryMode === "nft") {
              setCurrentToken(null);
            }
            requestParams.deliveryMode = "ftIdenticalAmount";
            requestParams.options.maxClaimableShares = 0;
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
            if (requestParams.deliveryMode === "nft") {
              setCurrentToken(null);
            }
            requestParams.deliveryMode = "ftRandomAmount";
            requestParams.options.maxClaimableShares = 0;
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
          disabled={true}
          on:click={() => {
            requestParams.deliveryMode = "nft";
            requestParams.options.maxClaimableShares = 0;
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
          required
          disabled={$txInProgress}
          bind:value={requestParams.options.threshold}
        />
      </label>
      {#if requestParams.deliveryMode !== "nft"}
        <FTlist
          balances={data.available?.tokenBalances}
          watchStatus={txStatus}
          on:select={(e) => {
            setCurrentToken(e.detail);
          }}
          on:balanceUpdated={(e) => {
            setCurrentToken(e.detail);
          }}
        />
        {#if currentToken}
          <div class="flex-wrap between flex-gap">
            <span class="emphasis">
              Strategy Cost: {requestParams.deliveryMode === "ftIdenticalAmount"
                ? (requestParams.options.deliveryParam1 ?? 0) *
                  (requestParams.options.maxClaimableShares ?? 0)
                : requestParams.options.deliveryParam1 ?? 0}
            </span>
            <span class="emphasis">Balance: {currentToken.balance}</span>
          </div>
          <hr />
          <div class="flex flex-gap mb-1">
            <label for="deliveryParam" class="flex-auto">
              <span>
                {#if requestParams.deliveryMode === "ftIdenticalAmount"}
                  Reward amount of each share
                {:else}
                  Reward amount in total
                {/if}
              </span>
              <input
                type="number"
                id="deliveryParam"
                name="deliveryParam"
                min="1"
                max={currentToken.balance}
                placeholder="ex. 100"
                step="10"
                required
                disabled={$txInProgress}
                bind:value={requestParams.options.deliveryParam1}
                on:change={(e) => {
                  requestParams.options.deliveryParam1 = Math.min(
                    requestParams.options.deliveryParam1,
                    currentToken.balance
                  );
                  if (requestParams.deliveryMode === "ftIdenticalAmount") {
                    requestParams.options.maxClaimableShares = Math.min(
                      requestParams.options.maxClaimableShares,
                      Math.floor(
                        currentToken.balance /
                          (requestParams.options.deliveryParam1 ?? 1)
                      )
                    );
                  }
                }}
              />
            </label>
            <!-- Range slider -->
            <label for="maxClaimableShares">
              <span>
                Total Shares:
                {requestParams.options.maxClaimableShares ?? 0}
              </span>
              {#if requestParams.deliveryMode === "ftIdenticalAmount"}
                <input
                  type="range"
                  id="maxClaimableShares"
                  name="maxClaimableShares"
                  min="1"
                  max={Math.floor(
                    currentToken.balance /
                      (requestParams.options.deliveryParam1 ?? 1)
                  )}
                  required
                  disabled={$txInProgress ||
                    !requestParams.options.deliveryParam1}
                  bind:value={requestParams.options.maxClaimableShares}
                />
              {:else}
                <input
                  type="number"
                  id="maxClaimableShares"
                  name="maxClaimableShares"
                  min="1"
                  max="10000"
                  placeholder="ex. 100"
                  step="10"
                  required
                  disabled={$txInProgress}
                  bind:value={requestParams.options.maxClaimableShares}
                  on:change={(e) => {
                    requestParams.options.maxClaimableShares = Math.min(
                      requestParams.options.maxClaimableShares,
                      10000
                    );
                  }}
                />
              {/if}
            </label>
          </div>
        {/if}
      {:else}
        TODO: NFT Config
      {/if}

      {#if requestParams.strategyMode === "lotteryStrategy"}
        <label for="minimumValidAmount">
          <span class:highlight={requestParams.options.minimumValidAmount > 0}>
            Minimum Amount of Eligible Users for the Raffle: {requestParams
              .options.minimumValidAmount}
          </span>
          <input
            type="range"
            id="minimumValidAmount"
            name="minimumValidAmount"
            min="1"
            max={requestParams.options.maxClaimableShares}
            required
            disabled={$txInProgress ||
              !requestParams.options.maxClaimableShares}
            bind:value={requestParams.options.minimumValidAmount}
          />
        </label>
      {/if}

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
  {/await}
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
