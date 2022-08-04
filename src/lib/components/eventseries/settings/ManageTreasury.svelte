<script>
  import Loading from "$lib/components/common/Loading.svelte";
  import FTlist from "$lib/components/common/FTlist.svelte";
  import { createEventDispatcher } from "svelte";
  import { user, eventSeries as seriesStore } from "$lib/flow/stores";
  import {
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
    };
  }

  function onToggleSelect(eventId) {
    // TODO
  }

  $: isValidToSubmit = false;

  function handleAddNewGoals() {
    if (!isValidToSubmit) return;

    // TODO
  }
</script>

{#if isValid}
  <details>
    <summary role="button" class="secondary">
      <b>Manage the treasury →</b>
    </summary>
    <div class="grid no-break mb-1">
      <button
        class:secondary={requestParams.type !== "depositFT"}
        class="outline"
        on:click={() => {
          requestParams.type = "depositFT";
          requestParams.amount = 0;
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
      <FTlist />
    {:else if requestParams.type === "depositNFT"}
      depositNFT
    {/if}
    {#if $txInProgress}
      <button aria-busy="true" disabled>
        Please wait for the transaction
      </button>
    {:else if $txStatus === false}
      <button
        on:click|preventDefault={handleAddNewGoals}
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
