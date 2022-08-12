<script>
  import { createEventDispatcher } from "svelte";
  import { cachedCollections } from "$lib/flow/stores";
  import { getCollections } from "$lib/flow/actions";

  /** @type {import('../eventseries/types').CollectionInfo} */
  export let collection = null;
  /** @type {string} */
  export let identifier = null;
  /** @type {string[]} */
  export let ids = [];
  /** @type {number} */
  export let amount = undefined;

  // dispatcher
  const dispatch = createEventDispatcher();

  async function getCollectionInfo(identifier) {
    let info = $cachedCollections[identifier];
    if (!info) {
      const collections = await getCollections(identifier);
      if (collections && collections[0]) {
        info = collections[0];
        cachedCollections.set(
          Object.assign({ [info.nftIdentifier]: info }, $cachedCollections)
        );
      }
    }
    return info;
  }

  $: collectionPromise = collection
    ? Promise.resolve(collection)
    : identifier
    ? getCollectionInfo(identifier)
    : Promise.resolve();
</script>

{#await collectionPromise then collectionInfo}
  {#if collectionInfo}
    <div
      class="flex-auto flex-wrap between flex-gap"
      on:click={(e) => {
        let obj = Object.assign({}, collectionInfo, {
          amount: amount ?? ids.length,
        });
        dispatch("select", obj);
      }}
    >
      <span>
        <img
          src={collectionInfo.display.squareImage.file?.url}
          class="icon"
          alt="{collectionInfo.display.name} logo"
        />
        &nbsp; {collectionInfo.display.name}
      </span>
      <div class="flex">
        <span class="emphasis">
          x {amount ?? ids.length}
        </span>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="highlight icon"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M12 8v13m0-13V6a2 2 0 112 2h-2zm0 0V5.5A2.5 2.5 0 109.5 8H12zm-7 4h14M5 12a2 2 0 110-4h14a2 2 0 110 4M5 12v7a2 2 0 002 2h10a2 2 0 002-2v-7"
          />
        </svg>
      </div>
    </div>
  {/if}
{/await}

<style>
  img.icon {
    height: 1.5rem;
    width: 1.5rem;
  }
  svg.icon {
    margin: 0 0.2rem;
    height: 1.2rem;
    width: 1.2rem;
  }
</style>
