<script>
  import { t } from "svelte-i18n";
  import FungibleTokenDisplay from "$lib/components/common/FungibleTokenDisplay.svelte";
  import NftCollectionDisplay from "$lib/components/common/NFTCollectionDisplay.svelte";
  import Stack from "$lib/components/eventseries/svgs/stack.svelte";
  import EnergyPoint from "$lib/components/eventseries/svgs/EnergyPoint.svelte";

  /**
   * @type {import('../types').StrategyDetail}
   */
  export let strategy;
  export let ready = false;
  export let done = false;
</script>

<article class="panel" class:ready class:done>
  <div class="panel-start flex flex-col flex-gap">
    {#if strategy.strategyMode === "raffleStrategy"}
      <svg
        t="1659950717064"
        class="icon"
        viewBox="0 0 1024 1024"
        version="1.1"
        xmlns="http://www.w3.org/2000/svg"
        p-id="2084"
      >
        <path
          d="M535.845 390.344L512 274.266l-22.045 115.807c-24.025 4.319-47.06 15.746-65.687 34.283-48.41 48.501-48.41 126.965 0 175.375 48.411 48.41 126.965 48.41 175.375 0 48.501-48.501 48.501-126.965 0-175.375-18.086-18.086-40.402-29.513-63.797-34.013m256.178 401.681L615.659 615.659c-18.896 18.896-41.662 31.493-65.687 37.972l64.607 241.062C581.556 903.511 547.092 908.01 512 908.01s-69.466-4.589-102.489-13.317l64.607-241.062c-24.115-6.389-46.791-19.075-65.687-37.972L232.066 792.024c-50.93-50.93-85.123-112.477-102.399-177.534l240.882-64.517a146.534 146.534 0 0 1 0-75.855l-240.882-64.517c17.276-65.057 51.38-126.605 102.31-177.534l176.365 176.365c18.896-18.896 41.572-31.493 65.687-37.972l-64.517-241.062c33.023-8.728 67.396-13.317 102.489-13.317s69.466 4.589 102.579 13.317L549.973 370.46c24.025 6.389 46.791 19.075 65.687 37.972l176.365-176.365c49.941 49.941 84.943 110.948 102.669 177.444l-241.151 64.607a146.534 146.534 0 0 1 0 75.855l241.062 64.607c-17.726 66.496-52.64 127.505-102.579 177.444m38.15-598.11C745.143 108.971 632.215 62.18 512 62.18c-120.127 0-233.143 46.791-318.086 131.734C108.881 278.857 62.09 391.875 62.09 512c0 120.216 46.791 233.143 131.824 318.176C278.857 915.209 391.875 961.91 512 961.91c120.216 0 233.143-46.791 318.176-131.734C915.209 745.233 961.91 632.215 961.91 512c0-120.127-46.791-233.143-131.734-318.086z"
          p-id="2085"
        />
      </svg>
    {:else}
      <svg
        t="1659950908266"
        class="icon"
        viewBox="0 0 1024 1024"
        version="1.1"
        xmlns="http://www.w3.org/2000/svg"
        p-id="4496"
        ><path
          d="M692.224 205.824c-29.696 0-55.296 21.504-65.536 51.2 38.912 17.408 68.608 55.296 78.848 101.376 31.744-7.168 55.296-37.888 55.296-74.752 0-44.032-30.72-77.824-68.608-77.824z m63.488 182.272c-13.312 12.288-29.696 20.48-48.128 23.552-3.072 27.648-13.312 53.248-28.672 73.728h113.664c14.336 0 25.6-11.264 25.6-25.6v-12.288c0-27.648-30.72-45.056-62.464-59.392zM647.168 512c-20.48 18.432-46.08 29.696-73.728 29.696-2.048 31.744-11.264 60.416-25.6 84.992h143.36c16.384 0 30.72-13.312 30.72-30.72V583.68c-1.024-33.792-37.888-54.272-74.752-71.68zM515.072 667.648c-28.672 28.672-67.584 45.056-108.544 45.056-41.984 0-80.896-17.408-109.568-47.104-47.104 22.528-92.16 51.2-92.16 93.184V778.24c0 22.528 18.432 39.936 39.936 39.936h320.512c22.528 0 39.936-18.432 39.936-39.936v-18.432c0-43.008-43.008-70.656-90.112-92.16z"
          p-id="4497"
        /><path
          d="M295.936 528.384a120.832 109.568 90 1 0 219.136 0 120.832 109.568 90 1 0-219.136 0Z"
          p-id="4498"
        /><path
          d="M570.368 302.08c-37.888 0-69.632 27.648-78.848 66.56 37.888 24.576 65.536 66.56 76.8 114.688h2.048c45.056 0 81.92-40.96 81.92-91.136 1.024-49.152-35.84-90.112-81.92-90.112z"
          p-id="4499"
        /></svg
      >
    {/if}
  </div>
  <div class="panel-content flex-auto">
    <div class="flex-wrap between">
      <div
        class="panel-tag"
        class:alert-warning={strategy.currentState === "preparing"}
        class:alert-info={strategy.currentState === "pending"}
        class:alert-success={strategy.currentState === "claimable"}
        class:alert-danger={strategy.currentState === "closed"}
      >
        {strategy.currentState.toUpperCase()}
      </div>
      <span>
        {$t("challenges.elements.strategy.display.require")}&nbsp;
        <span class="highlight">
          {strategy.strategyData.threshold}
          {#if strategy.strategyData.consumable}
            <EnergyPoint />
          {:else}
            {$t("challenges.elements.strategy.display.points")}
          {/if}
        </span>
      </span>
    </div>
    <div class="flex-wrap between">
      <span>
        {$t("challenges.elements.strategy.display.remaining", {
          values: { n: "" },
        })}
        <span class="highlight">
          {strategy.deliveryStatus.maxClaimableShares -
            strategy.deliveryStatus.claimedShares}
        </span>
        / {strategy.deliveryStatus.maxClaimableShares}
        <Stack />
      </span>
      <span
        data-tooltip={strategy.deliveryMode === "ftIdenticalAmount"
          ? "Each reward is a identical amount"
          : strategy.deliveryMode === "ftRandomAmount"
          ? "Each reward is a random amount"
          : "Reward is a share of NFT"}
      >
        {#if strategy.deliveryMode === "ftIdenticalAmount"}
          <span class="highlight">{strategy.deliveryStatus.oneShareAmount}</span
          >
          / <Stack />
        {:else if strategy.deliveryMode === "ftRandomAmount"}
          <span class="highlight">{strategy.deliveryStatus.totalAmount}</span>
          {$t("challenges.elements.strategy.display.in-total")}
        {:else}
          <span class="highlight">
            {$t("challenges.elements.strategy.display.one-share")}
          </span>
          / <Stack />
        {/if}
      </span>
    </div>
    <div class="flex-wrap between flex-gap">
      <span class="flex-none">
        {$t("challenges.elements.strategy.display.treasury")}
      </span>
      {#if strategy.deliveryMode !== "nft"}
        <FungibleTokenDisplay
          identifier={strategy.deliveryStatus.deliveryTokenIdentifier}
          balance={strategy.deliveryStatus.restAmount}
        />
      {:else}
        <NftCollectionDisplay
          identifier={strategy.deliveryStatus.deliveryTokenIdentifier}
          amount={strategy.deliveryStatus.maxClaimableShares -
            strategy.deliveryStatus.claimedShares}
        />
      {/if}
    </div>
    {#if strategy.strategyMode === "raffleStrategy" && strategy.currentState === "pending"}
      <div class="flex-wrap between">
        <span>
          {$t("challenges.elements.strategy.display.eligible-users")}
          <span class="highlight">{strategy.strategyData.valid?.length}</span>
          {$t("challenges.elements.strategy.display.at-least", {
            values: { n: strategy.strategyData.minValid },
          })}
        </span>
        <progress
          style="margin-top: 0.25rem;"
          value={strategy.strategyData.valid?.length}
          max={strategy.strategyData.minValid}
        />
      </div>
    {/if}
  </div>
  <slot />
</article>
<slot name="bottom">
  <div class="panel-bottom" />
</slot>

<style>
  .panel {
    margin-bottom: 0rem;
  }

  .panel-content {
    padding: 0.8rem 0.8rem 0.8rem 0;
    display: flex;
    flex-direction: column;
    gap: 0.4rem;
  }

  .panel-start .icon {
    width: 3rem;
    height: 3rem;
  }
</style>
