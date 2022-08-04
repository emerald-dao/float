<script>
  import { createEventDispatcher } from "svelte";
  import { user } from "$lib/flow/stores";
  import { getCollectionsNotEmpty } from "$lib/flow/actions";

  // dispatcher
  const dispatch = createEventDispatcher();

  let currentCollection = undefined;
  let open = false;

  async function getOwnedList(address) {
    if (address) {
      const result = await getCollectionsNotEmpty(address);
      console.log(result);
      return [];
    } else {
      return [];
    }
  } // end function

  $: ownedList = getOwnedList($user?.addr);
</script>

<details role="list" {open}>
  <summary
    aria-haspopup="listbox"
    on:click={(e) => {
      setTimeout(() => {
        if (!open) {
          open = true;
        }
      });
    }}
  >
    {#if !currentCollection}
      please choose your collection
    {:else}
      TODO
    {/if}
  </summary>
  <ul role="listbox">
    {#await ownedList then list}
      {#each list as one}
        <li>
          <!-- svelte-ignore a11y-missing-attribute -->
          <a
            on:click={(e) => {
              dispatch("select", one);
              currentCollection = one;
              open = false;
            }}
          >
            TODO
            <!-- <div class="flex-wrap between flex-gap">
              <span>
                <img src={token.logoURI} class="icon" alt="{token.name} logo" />
                &nbsp; {token.name}
              </span>
              <span class="emphasis">{token.balance}</span>
            </div> -->
          </a>
        </li>
      {:else}
        <li>You have no collection with NFTs (from NFTCatalog).</li>
      {/each}
    {/await}
  </ul>
</details>

<style>
  img.icon {
    height: 1.5rem;
    width: 1.5rem;
  }
</style>
