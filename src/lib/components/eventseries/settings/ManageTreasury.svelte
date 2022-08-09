<script>
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

  $: isValidToSubmit =
    requestParams.type === "depositFT"
      ? requestParams.amount > 0 &&
        requestParams.storagePath?.length > 0 &&
        requestParams.publicPath?.length > 0
      : requestParams.type === "depositNFT"
      ? requestParams.ids?.length > 0 &&
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
      <b>Manage the treasury →</b>
    </summary>
    <div class="grid no-break mb-1">
      <button
        class:secondary={requestParams.type !== "depositFT"}
        class="outline"
        disabled={$txInProgress}
        on:click={() => {
          requestParams.type = "depositFT";
          requestParams.amount = 0;
          setCurrentToken(null);
        }}
      >
        Deposit Token
        <span>
          Deposit any <b>Fungible Tokens</b> to the treasury of current Event Series.
        </span>
      </button>
      <button
        class:secondary={requestParams.type !== "depositNFT"}
        class="outline"
        disabled={true}
        on:click={() => {
          requestParams.type = "depositNFT";
          requestParams.ids = [];
        }}
      >
        Deposit NFT
        <span>
          Deposit any <b>NFTs</b> to the treasury of current Event Series.
        </span>
      </button>
      <button
        class:secondary={requestParams.type !== "dropAll"}
        class="outline"
        disabled={$txInProgress}
        on:click={() => {
          requestParams.type = "dropAll";
        }}
      >
        Drop Treasury
        <span>
          Drop <b>ALL</b> assets in the treasury and transfer to owner's account.
        </span>
      </button>
    </div>
    {#if requestParams.type === "depositFT"}
      <FTlist
        watchStatus={txStatus}
        on:select={(e) => {
          setCurrentToken(e.detail);
        }}
        on:balanceUpdated={(e) => {
          setCurrentToken(e.detail);
        }}
      />
      {#if currentToken}
        <div class="flex flex-gap mb-1">
          <label for="tokenAmount" class="flex-auto">
            <span> Deposit Amount </span>
            <input
              type="number"
              id="tokenAmount"
              name="tokenAmount"
              placeholder="0"
              min="0"
              max={currentToken.balance}
              required
              disabled={$txInProgress}
              bind:value={requestParams.amount}
              on:change={(e) => {
                requestParams.amount = Math.min(
                  requestParams.amount,
                  currentToken.balance
                );
              }}
            />
          </label>
          <!-- Range slider -->
          <label for="amountSlider">
            <span class="highlight">
              Max:
              {currentToken.balance}
            </span>
            <input
              type="range"
              id="amountSlider"
              name="amountSlider"
              min="0"
              max={currentToken.balance}
              disabled={$txInProgress}
              bind:value={requestParams.amount}
            />
          </label>
        </div>
      {/if}
    {:else if requestParams.type === "depositNFT"}
      <NftCollections />
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
        {#if requestParams.type === "depositFT"}
          Deposit Tokens
        {:else if requestParams.type === "depositNFT"}
          Deposit NFTs
        {:else}
          Drop ALL ASSETs
        {/if}
      </button>
    {:else}
      {#if $txStatus.success}
        <p>Treasury updated successfully!</p>
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
