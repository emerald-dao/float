<script>
  import { t } from "svelte-i18n";
  import Loading from "$lib/components/common/Loading.svelte";
  import FTlist from "$lib/components/common/FTlist.svelte";
  import EnergyPoint from "$lib/components/eventseries/svgs/EnergyPoint.svelte";
  import StrategyControllerItem from "../elements/StrategyControllerItem.svelte";
  import { createEventDispatcher } from "svelte";
  import { user, eventSeries as seriesStore } from "$lib/flow/stores";
  import { getSeriesStrategies, addTreasuryStrategy } from "$lib/flow/actions";
  import NftCollections from "$lib/components/common/NFTCollections.svelte";

  /** @type {import('../types').EventSeriesData} */
  export let eventSeries;

  // dispatcher
  const dispatch = createEventDispatcher();

  $: isValid = eventSeries.identifier.host === $user?.addr;

  /** @type {import('../types').AddStrategyRequest} */
  let requestParams;
  /** @type {Promise<import('../types').StrategyQueryResult>} */
  let strategiesPromise;
  /** @type {import('flow-native-token-registry').TokenInfo & {balance: number}} */
  let currentToken;
  /** @type {import('../types').CollectionInfo & {amount: number}} */
  let currentCollection;

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

    reloadStrategies();
  }

  function reloadStrategies() {
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

  /**
   * @param {import('../types').CollectionInfo & {amount: number}} collection
   */
  function setCurrentCollection(collection) {
    if (collection) {
      currentCollection = collection;
      requestParams.options.deliveryTokenIdentifier = collection.nftIdentifier;
    } else {
      currentCollection = null;
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
    (requestParams.strategyMode === "raffleStrategy"
      ? requestParams.options.minimumValidAmount >=
        requestParams.options.maxClaimableShares
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
    <div class="mb-1">
      {#each data.strategies as strategy}
        <StrategyControllerItem
          {eventSeries}
          {strategy}
          on:seriesUpdated={reloadStrategies}
        />
      {/each}
    </div>
    <details>
      <summary role="button" class="secondary">
        <b>{$t("challenges.detail.settings.strategy.title")}</b>
      </summary>

      <div class="grid no-break mb-1">
        <button
          class:secondary={requestParams.strategyMode !== "queueStrategy"}
          class="outline"
          disabled={$txInProgress}
          on:click={function () {
            requestParams.strategyMode = "queueStrategy";
            requestParams.options.minimumValidAmount = undefined;
          }}
        >
          {$t("challenges.detail.settings.strategy.select-queue")}
          <span>
            {$t("challenges.detail.settings.strategy.select-queue-desc")}
          </span>
        </button>
        <button
          class:secondary={requestParams.strategyMode !== "raffleStrategy"}
          class="outline"
          disabled={$txInProgress}
          on:click={function () {
            requestParams.strategyMode = "raffleStrategy";
            requestParams.options.minimumValidAmount = 0;
          }}
        >
          {$t("challenges.detail.settings.strategy.select-raffle")}
          <span>
            {$t("challenges.detail.settings.strategy.select-raffle-desc")}
          </span>
        </button>
      </div>
      <div class="grid no-break mb-1">
        <button
          class:secondary={requestParams.deliveryMode !== "ftIdenticalAmount"}
          class="outline"
          disabled={$txInProgress}
          on:click={function () {
            if (requestParams.deliveryMode === "nft") {
              setCurrentToken(null);
            }
            requestParams.deliveryMode = "ftIdenticalAmount";
            requestParams.options.maxClaimableShares = 0;
            requestParams.options.deliveryParam1 = 0;
          }}
        >
          {$t("challenges.detail.settings.strategy.select-identical-amt")}
          <span>
            {@html $t(
              "challenges.detail.settings.strategy.select-identical-amt-desc"
            )}
          </span>
        </button>
        <button
          class:secondary={requestParams.deliveryMode !== "ftRandomAmount"}
          class="outline"
          disabled={$txInProgress}
          on:click={function () {
            if (requestParams.deliveryMode === "nft") {
              setCurrentToken(null);
            }
            requestParams.deliveryMode = "ftRandomAmount";
            requestParams.options.maxClaimableShares = 0;
            requestParams.options.deliveryParam1 = 0;
          }}
        >
          {$t("challenges.detail.settings.strategy.select-random-amt")}
          <span>
            {@html $t(
              "challenges.detail.settings.strategy.select-random-amt-desc"
            )}
          </span>
        </button>
        <button
          class:secondary={requestParams.deliveryMode !== "nft"}
          class="outline"
          disabled={$txInProgress}
          on:click={function () {
            if (requestParams.deliveryMode !== "nft") {
              setCurrentCollection(null);
            }
            requestParams.deliveryMode = "nft";
            requestParams.options.maxClaimableShares = 0;
            requestParams.options.deliveryParam1 = undefined;
          }}
        >
          {$t("common.main.nft")}
          <span>
            {@html $t(
              "challenges.detail.settings.strategy.select-nft-deliver-desc"
            )}
          </span>
        </button>
      </div>

      <div class="flex flex-gap mb-1">
        <label for="threshold" class="flex-auto">
          <span class:highlight={requestParams.options.threshold > 0}>
            {$t("challenges.detail.settings.strategy.label-eligible-threshold")}
          </span>
          <input
            type="number"
            id="threshold"
            name="threshold"
            min="1"
            max="10000000"
            placeholder={$t("common.hint.placeholder-ex", {
              values: { ex: 100 },
            })}
            step="100"
            required
            disabled={$txInProgress}
            bind:value={requestParams.options.threshold}
          />
        </label>
        <label for="consumable">
          <input
            type="checkbox"
            id="consumable"
            name="consumable"
            role="switch"
            disabled={$txInProgress}
            bind:checked={requestParams.options.consumable}
          />
          {$t("common.label.use")}
          <EnergyPoint />
        </label>
      </div>
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
              {$t("challenges.detail.settings.strategy.label-cost", {
                values: {
                  cost:
                    requestParams.deliveryMode === "ftIdenticalAmount"
                      ? (requestParams.options.deliveryParam1 ?? 0) *
                        (requestParams.options.maxClaimableShares ?? 0)
                      : requestParams.options.deliveryParam1 ?? 0,
                },
              })}
            </span>
            <span class="emphasis">
              {$t("challenges.detail.settings.strategy.label-balance", {
                values: { balance: currentToken.balance },
              })}
            </span>
          </div>
          <hr />
          <div class="flex flex-gap mb-1">
            <label for="deliveryParam" class="flex-auto">
              <span>
                {requestParams.deliveryMode === "ftIdenticalAmount"
                  ? $t(
                      "challenges.detail.settings.strategy.label-reward-identical"
                    )
                  : $t(
                      "challenges.detail.settings.strategy.label-reward-random"
                    )}
              </span>
              <input
                type="number"
                id="deliveryParam"
                name="deliveryParam"
                min="1"
                max={currentToken.balance}
                placeholder={$t("common.hint.placeholder-ex", {
                  values: { ex: 100 },
                })}
                step="10"
                required
                disabled={$txInProgress}
                bind:value={requestParams.options.deliveryParam1}
                on:change={function (e) {
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
                {$t("challenges.detail.settings.strategy.label-total-shares", {
                  values: {
                    share: requestParams.options.maxClaimableShares ?? 0,
                  },
                })}
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
                  placeholder={$t("common.hint.placeholder-ex", {
                    values: { ex: 100 },
                  })}
                  step="10"
                  required
                  disabled={$txInProgress}
                  bind:value={requestParams.options.maxClaimableShares}
                  on:change={(e) => {
                    requestParams.options.maxClaimableShares = Math.min(
                      requestParams.options.maxClaimableShares,
                      10000
                    );
                    if (requestParams.strategyMode === "raffleStrategy") {
                      requestParams.options.minimumValidAmount = Math.max(
                        requestParams.options.minimumValidAmount,
                        requestParams.options.maxClaimableShares
                      );
                    }
                  }}
                />
              {/if}
            </label>
          </div>
        {/if}
      {:else}
        <NftCollections
          collections={data.available?.collectionIDs}
          watchStatus={txStatus}
          on:select={(e) => {
            setCurrentCollection(e.detail);
          }}
          on:amountUpdated={(e) => {
            setCurrentCollection(e.detail);
          }}
        />
        {#if currentCollection}
          <div class="flex-wrap between flex-gap">
            <span class="emphasis">
              {$t("challenges.detail.settings.strategy.label-cost", {
                values: {
                  cost: requestParams.options.maxClaimableShares ?? 0,
                },
              })}
            </span>
            <span class="emphasis">
              {$t("challenges.elements.strategy.display.remaining", {
                values: { n: currentCollection.amount },
              })}
            </span>
          </div>
          <hr />
          <!-- Range slider -->
          <label for="maxClaimableShares">
            <span>
              {$t("challenges.detail.settings.strategy.label-total-shares", {
                values: {
                  shares: requestParams.options.maxClaimableShares ?? 0,
                },
              })}
            </span>
            <input
              type="range"
              id="maxClaimableShares"
              name="maxClaimableShares"
              min="1"
              max={currentCollection.amount}
              required
              disabled={$txInProgress}
              bind:value={requestParams.options.maxClaimableShares}
            />
          </label>
        {/if}
      {/if}

      {#if requestParams.strategyMode === "raffleStrategy"}
        <label for="minimumValidAmount">
          <span class:highlight={requestParams.options.minimumValidAmount > 0}>
            {$t("challenges.detail.settings.strategy.label-min-valid-users", {
              values: {
                amount: requestParams.options.minimumValidAmount,
              },
            })}
          </span>
          <input
            type="range"
            id="minimumValidAmount"
            name="minimumValidAmount"
            min={requestParams.options.maxClaimableShares}
            max={requestParams.options.maxClaimableShares * 5}
            required
            disabled={$txInProgress ||
              !requestParams.options.maxClaimableShares}
            bind:value={requestParams.options.minimumValidAmount}
          />
        </label>
      {/if}

      {#if $txInProgress}
        <button aria-busy="true" disabled>
          {$t("common.hint.please-wait-for-tx")}
        </button>
      {:else if $txStatus === false}
        <button
          on:click|preventDefault={handleSubmit}
          disabled={!isValidToSubmit}
        >
          {$t("challenges.detail.settings.strategy.btn-submit")}
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
