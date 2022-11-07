<script>
  import { t } from "svelte-i18n";
  import Loading from "$lib/components/common/Loading.svelte";
  import FTlist from "$lib/components/common/FTlist.svelte";
  import FungibleTokenDisplay from "$lib/components/common/FungibleTokenDisplay.svelte";
  import NftCollections from "$lib/components/common/NFTCollections.svelte";
  import NFTCollectionDisplay from "$lib/components/common/NFTCollectionDisplay.svelte";
  import { createEventDispatcher } from "svelte";
  import { user, eventSeries as seriesStore } from "$lib/flow/stores";
  import {
    getTreasuryData,
    depositFungibleTokenToTreasury,
    depositNonFungibleTokenToTreasury,
    dropTreasury,
  } from "$lib/flow/actions";

  /** @type {import('../types').EventSeriesData} */
  export let eventSeries;

  // dispatcher
  const dispatch = createEventDispatcher();

  $: isValid = eventSeries.identifier.host === $user?.addr;

  /** @type {import('../types').TreasuryManagementRequeset} */
  let requestParams;
  /** @type {Promise<import('../types').TreasuryData>} */
  let treasuryPromise;
  /** @type {import('flow-native-token-registry').TokenInfo & {balance: number}} */
  let currentToken;
  /** @type {import('../types').CollectionInfo & {amount: number}} */
  let currentCollection;

  const txInProgress = seriesStore.TreasuryManegement.InProgress;
  const txStatus = seriesStore.TreasuryManegement.Status;

  // init with false
  handleReset();

  function handleReset() {
    if ($txStatus?.success) {
      dispatch("seriesUpdated");
    }
    txInProgress.set(false);
    txStatus.set(false);

    requestParams = {
      type: "depositFT",
      seriesId: eventSeries.identifier.id,
      amount: 0,
    };

    treasuryPromise = getTreasuryData(
      eventSeries.identifier.host,
      eventSeries.identifier.id
    );
  }

  /**
   * @param {import('flow-native-token-registry').TokenInfo} token
   */
  function setCurrentToken(token) {
    if (token) {
      currentToken = token;
      requestParams.storagePath = token?.path?.vault?.slice("/storage/".length);
      requestParams.publicPath = token?.path?.receiver?.slice(
        "/public/".length
      );
    } else {
      currentToken = null;
    }
  }

  /**
   * @param {import('../types').CollectionInfo & {amount: number}} collection
   */
  function setCurrentCollection(collection) {
    if (collection) {
      currentCollection = collection;
      requestParams.storagePath = collection.storagePath.identifier;
      requestParams.publicPath = collection.publicPath.identifier;
    } else {
      currentCollection = null;
    }
  }

  $: isValidToSubmit =
    requestParams.type === "depositFT"
      ? requestParams.amount > 0 &&
        requestParams.storagePath?.length > 0 &&
        requestParams.publicPath?.length > 0
      : requestParams.type === "depositNFT"
      ? requestParams.amount > 0 &&
        requestParams.storagePath?.length > 0 &&
        requestParams.publicPath?.length > 0
      : true;

  function handleSubmit() {
    if (!isValidToSubmit) return;

    switch (requestParams.type) {
      case "depositFT":
        depositFungibleTokenToTreasury(requestParams);
        break;
      case "depositNFT":
        depositNonFungibleTokenToTreasury(requestParams);
        break;
      case "dropAll":
        dropTreasury(requestParams);
        break;
    }
  }
</script>

{#if isValid}
  {#await treasuryPromise}
    <Loading />
  {:then data}
    <div class="no-break flex-col flex-gap mb-1">
      {#each data.tokenBalances as one}
        <FungibleTokenDisplay
          identifier={one.identifier}
          balance={one.balance}
        />
      {/each}
      {#each data.collectionIDs as one}
        <NFTCollectionDisplay identifier={one.identifier} ids={one.ids} />
      {/each}
    </div>
  {/await}
  <details>
    <summary role="button" class="secondary">
      <b>{$t("challenges.detail.settings.treasury.title")}</b>
    </summary>
    <div class="grid no-break mb-1">
      <button
        class:secondary={requestParams.type !== "depositFT"}
        class="outline"
        disabled={$txInProgress}
        on:click={function () {
          requestParams.type = "depositFT";
          requestParams.amount = 0;
          setCurrentToken(null);
        }}
      >
        {$t("challenges.detail.settings.treasury.select-deposit-ft")}
        <span>
          {@html $t(
            "challenges.detail.settings.treasury.select-deposit-ft-desc"
          )}
        </span>
      </button>
      <button
        class:secondary={requestParams.type !== "depositNFT"}
        class="outline"
        disabled={$txInProgress}
        on:click={function () {
          requestParams.type = "depositNFT";
          requestParams.amount = 0;
          setCurrentCollection(null);
        }}
      >
        {$t("challenges.detail.settings.treasury.select-deposit-nft")}
        <span>
          {@html $t(
            "challenges.detail.settings.treasury.select-deposit-nft-desc"
          )}
        </span>
      </button>
      <button
        class:secondary={requestParams.type !== "dropAll"}
        class="outline"
        disabled={$txInProgress}
        on:click={function () {
          requestParams.type = "dropAll";
        }}
      >
        {$t("challenges.detail.settings.treasury.select-drop")}
        <span>
          {@html $t("challenges.detail.settings.treasury.select-drop-desc")}
        </span>
      </button>
    </div>
    {#if requestParams.type !== "dropAll"}
      {#if requestParams.type === "depositFT"}
        <FTlist
          loadBalance={true}
          watchStatus={txStatus}
          on:select={function (e) {
            setCurrentToken(e.detail);
          }}
          on:balanceUpdated={function (e) {
            setCurrentToken(e.detail);
          }}
        />
      {:else}
        <NftCollections
          loadBalance={true}
          watchStatus={txStatus}
          on:select={function (e) {
            setCurrentCollection(e.detail);
          }}
          on:amountUpdated={function (e) {
            setCurrentCollection(e.detail);
          }}
        />
      {/if}

      {#if (requestParams.type === "depositFT" && currentToken) || (requestParams.type === "depositNFT" && currentCollection)}
        <div class="flex flex-gap mb-1">
          <label for="tokenAmount" class="flex-auto">
            <span>
              {$t("challenges.detail.settings.treasury.label-deposit")}
            </span>
            <input
              type="number"
              id="tokenAmount"
              name="tokenAmount"
              placeholder="0"
              min="0"
              max={requestParams.type === "depositFT"
                ? currentToken.balance
                : currentCollection.amount}
              required
              disabled={$txInProgress}
              bind:value={requestParams.amount}
              on:change={function (e) {
                requestParams.amount = Math.min(
                  requestParams.amount,
                  requestParams.type === "depositFT"
                    ? currentToken.balance
                    : currentCollection.amount
                );
              }}
            />
          </label>
          <!-- Range slider -->
          <label for="amountSlider">
            <span class="highlight">
              {$t("challenges.detail.settings.treasury.label-max", {
                values: {
                  amount:
                    requestParams.type === "depositFT"
                      ? currentToken.balance
                      : currentCollection.amount,
                },
              })}
            </span>
            <input
              type="range"
              id="amountSlider"
              name="amountSlider"
              min="0"
              max={requestParams.type === "depositFT"
                ? currentToken.balance
                : currentCollection.amount}
              disabled={$txInProgress}
              bind:value={requestParams.amount}
            />
          </label>
        </div>
      {/if}
    {:else if requestParams.type === "depositNFT"}{/if}
    {#if $txInProgress}
      <button aria-busy="true" disabled>
        {$t("common.hint.please-wait-for-tx")}
      </button>
    {:else if $txStatus === false}
      <button
        on:click|preventDefault={handleSubmit}
        disabled={!isValidToSubmit}
      >
        {requestParams.type === "depositFT"
          ? $t("challenges.detail.settings.treasury.btn-submit-deposit-ft")
          : requestParams.type === "depositNFT"
          ? $t("challenges.detail.settings.treasury.btn-submit-deposit-nft")
          : $t("challenges.detail.settings.treasury.btn-submit-drop")}
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
