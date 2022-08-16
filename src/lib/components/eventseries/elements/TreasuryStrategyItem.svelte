<script>
  import { t } from "svelte-i18n";
  import StrategyDisplay from "./StrategyDisplay.svelte";
  import { createEventDispatcher } from "svelte";
  import {
    user,
    eventSeries as seriesStore,
    getLatestTokenList,
  } from "$lib/flow/stores";
  import { claimTreasuryRewards } from "$lib/flow/actions";

  /** @type {import('../types').EventSeriesData} */
  export let eventSeries;
  /**
   * @type {import('../types').StrategyDetail}
   */
  export let strategy;
  export let totalScore = undefined;
  export let consumableScore = undefined;

  // dispatcher
  const dispatch = createEventDispatcher();

  const txInProgress = seriesStore.ClaimTreasuryRewards.InProgress;
  const txStatus = seriesStore.ClaimTreasuryRewards.Status;
  const txKey = seriesStore.ClaimTreasuryRewards.Key;

  $: preview = !$user?.addr;
  $: progress = Math.min(
    100,
    Math.floor(
      (100 *
        (strategy.strategyData.consumable ? consumableScore : totalScore)) /
        strategy.strategyData.threshold
    )
  );
  $: isCurrentItem = $txKey === strategy.index;
  $: isValidToSubmit =
    !preview &&
    !strategy.userStatus?.claimed &&
    strategy.currentState === "claimable" &&
    strategy.userStatus?.claimable;
  $: isClaimed = !preview && strategy.userStatus?.claimed;

  function handleReset() {
    if ($txStatus?.success) {
      dispatch("seriesUpdated");
    }
    txInProgress.set(false);
    txStatus.set(false);
    txKey.set(-1);
  }

  async function handleSubmit() {
    if (!isValidToSubmit) return;

    txKey.set(strategy.index);

    let identifier = strategy.deliveryStatus.deliveryTokenIdentifier;
    if (!identifier) return;

    let tokenIdInfo = identifier.split("."); // A.{address}.{contract}.Collection|Vault

    // setup additionalMap
    const additionalMap = {
      PLACEHOLDER_CONTRACT: tokenIdInfo[2],
      PLACEHOLDER_ADDRESS: `0x${tokenIdInfo[1]}`,
      PLACEHOLDER_STORAGE_PATH: "/storage/unknown",
      PLACEHOLDER_FT_RECEIVER_PATH: "/public/unknown",
      PLACEHOLDER_FT_BALANCE_PATH: "/public/unknown",
    };
    const isNFT = strategy.deliveryMode === "nft";
    if (!isNFT) {
      const allList = await getLatestTokenList();
      const tokenData = allList.find(
        (one) =>
          identifier === `A.${one.address.slice(2)}.${one.contractName}.Vault`
      );
      if (!tokenData) return;
      additionalMap.PLACEHOLDER_STORAGE_PATH = tokenData.path.vault;
      additionalMap.PLACEHOLDER_FT_RECEIVER_PATH = tokenData.path.receiver;
      additionalMap.PLACEHOLDER_FT_BALANCE_PATH = tokenData.path.balance;
    }

    claimTreasuryRewards(
      eventSeries.identifier.host,
      eventSeries.identifier.id,
      strategy.index,
      isNFT,
      additionalMap
    );
  }
</script>

<StrategyDisplay {strategy} ready={isValidToSubmit} done={isClaimed}>
  {#if !preview && !isClaimed}
    <div class="panel-bg" style="width: {progress}%;" />
  {/if}

  <div slot="bottom" class="panel-bottom">
    {#if !preview}
      {#if $txInProgress && isCurrentItem}
        <button aria-busy="true" disabled>
          {$t("common.hint.please-wait-for-tx")}
        </button>
      {:else if !isCurrentItem || $txStatus === false}
        {#if strategy.userStatus?.claimed}
          <button class="secondary outline" disabled>
            {$t("common.hint.claimed-reward")}
          </button>
        {:else if !isValidToSubmit}
          {#if !strategy.userStatus?.eligible && (strategy.strategyMode === "queueStrategy" || strategy.currentState === "opening")}
            <button disabled>
              {$t("errors.challenges.not-eligible-user-need-points")}
            </button>
          {:else if strategy.currentState !== "claimable"}
            <button disabled>
              {$t("errors.challenges.wait-for-claimable")}
            </button>
          {:else}
            <button class="secondary outline" disabled>
              {$t("errors.challenges.not-eligible-to-claim")}
            </button>
          {/if}
        {:else}
          <button
            on:click|preventDefault={handleSubmit}
            disabled={!isValidToSubmit}
          >
            {$t("challenges.elements.strategy.claim-reward")}
          </button>
        {/if}
      {:else if isCurrentItem}
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
  </div>
</StrategyDisplay>
