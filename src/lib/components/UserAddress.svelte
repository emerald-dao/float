<script>
  import { resolveAddressObject } from "$lib/flow/actions";
  import { getResolvedName } from "$lib/flow/utils";

  export let address;
  export let abbreviated = true;

  async function initialize(address) {
    let addressObject = await resolveAddressObject(address);
    return getResolvedName(addressObject)
  }
  let resolvedName = initialize(address || "");
</script>

<style>
  .led-green {
    position:relative;
    display:inline-block;
    top: 0px;
    margin-right:0.5em;
    background-color: var(--primary);
    width: 14px;
    height: 14px;
    border-radius: 14px;
  }

  @media screen and (max-width: 500px) {
    .led-green {
      display: none;
    }
  }
</style>

{#await resolvedName}
  <a aria-busy="true"></a>
{:then resolvedName}
  {#if !abbreviated}
    <span class="mono">{resolvedName}</span>
  {:else}
    <span class="led-green"></span>
    <span class="mono">{resolvedName.split('.')[0].length > 14 ? '0x...' + resolvedName.slice(resolvedName.length - 6) : resolvedName.length > 14 ? "..." + resolvedName.slice(resolvedName.length - 6) : resolvedName}</span>
  {/if}
{/await}