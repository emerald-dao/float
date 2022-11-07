<script>
  import { createEventDispatcher } from "svelte";
  import { getLatestTokenList } from "$lib/flow/stores";

  /** @type {import('flow-native-token-registry').TokenInfo} */
  export let token = undefined;
  /** @type {string} */
  export let identifier = undefined;
  /** @type {string} */
  export let balance;

  // dispatcher
  const dispatch = createEventDispatcher();

  async function getTokenInfo(identifier) {
    const allList = await getLatestTokenList();
    return allList.find(
      (one) =>
        identifier === `A.${one.address.slice(2)}.${one.contractName}.Vault`
    );
  }

  $: tokenPromise = token
    ? Promise.resolve(token)
    : identifier
    ? getTokenInfo(identifier)
    : Promise.resolve();
</script>

{#await tokenPromise then tokenInfo}
  {#if tokenInfo}
    <div
      class="flex-auto flex-wrap between flex-gap"
      on:click={(e) => {
        dispatch("select", Object.assign({}, tokenInfo, { balance }));
      }}
    >
      <span>
        <img src={tokenInfo.logoURI} class="icon" alt="{tokenInfo.name} logo" />
        &nbsp; {tokenInfo.name}
      </span>
      <span class="emphasis">{balance}</span>
    </div>
  {/if}
{/await}

<style>
  img.icon {
    height: 1.5rem;
    width: 1.5rem;
  }
</style>
