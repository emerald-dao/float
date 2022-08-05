<script>
  import { getLatestTokenList } from "$lib/flow/stores";

  /** @type {string} */
  export let identifier;
  /** @type {string} */
  export let balance;

  async function getTokenInfo(identifier) {
    const allList = await getLatestTokenList();
    return allList.find(
      (one) =>
        identifier === `A.${one.address.slice(2)}.${one.contractName}.Vault`
    );
  }

  $: token = getTokenInfo(identifier);
</script>

<div class="flex-wrap between flex-gap">
  {#await token then token}
    {#if token}
      <span>
        <img src={token.logoURI} class="icon" alt="{token.name} logo" />
        &nbsp; {token.name}
      </span>
      <span class="emphasis">{balance}</span>
    {/if}
  {/await}
</div>

<style>
  img.icon {
    height: 1.5rem;
    width: 1.5rem;
  }
</style>
