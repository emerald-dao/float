<script>
  import { createEventDispatcher } from "svelte";
  import { user } from "$lib/flow/stores";
  import { getCollectionsNotEmpty } from "$lib/flow/actions";
  import NftCollectionDisplay from "./NFTCollectionDisplay.svelte";

  /** @type {[{ nftIdentifier: string , amount: string }]} */
  export let collections = [];
  export let loadBalance = false;
  export let watchStatus = null;

  // dispatcher
  const dispatch = createEventDispatcher();

  /** @type {import('../eventseries/types').CollectionInfo} */
  let currentCollection = undefined;
  let open = false;

  async function getOwnedList(address) {
    let collectionsToFill = collections;
    if (collectionsToFill.length === 0 && address && loadBalance) {
      collectionsToFill = await getCollectionsNotEmpty(address);
    }
    // update current balance
    if (currentCollection) {
      const found = collectionsToFill.find(
        (one) => one.nftIdentifier === currentCollection.nftIdentifier
      );
      if (found) {
        currentCollection.amount = found.amount;
      }
      dispatch("amountUpdated", currentCollection);
    }
    return collectionsToFill ?? [];
  } // end function

  $: ownedList = getOwnedList($user?.addr, watchStatus && $watchStatus);
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
      <img
        src={currentCollection.display.squareImage.file?.url}
        class="icon"
        alt="current Collection logo"
      />
      &nbsp; {currentCollection.display.name}
    {/if}
  </summary>
  <ul role="listbox">
    {#await ownedList then list}
      {#each list as one}
        <li>
          <!-- svelte-ignore a11y-missing-attribute -->
          <a>
            <NftCollectionDisplay
              collection={one.key ? one : undefined}
              identifier={one.nftIdentifier}
              amount={parseInt(one.amount)}
              on:select={(e) => {
                dispatch("select", e.detail);
                currentCollection = Object.assign({}, one);
                open = false;
              }}
            />
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
