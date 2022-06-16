<script>
  import { resolveAddressObject } from "$lib/flow/actions";
  import { getResolvedName } from "$lib/flow/utils";
  import Loading from "../common/Loading.svelte";
  import SeriesCardDisplay from "./elements/SeriesCardDisplay.svelte";

  /** @type {import('./types').EventSeriesData} */
  export let eventSeriesData = {};
  export let preview = false;

  async function initialize() {
    let addressObject = await resolveAddressObject(
      eventSeriesData?.identifier?.host
    );
    return await getResolvedName(addressObject);
  }
</script>

{#await initialize()}
  <Loading />
{:then ownerName}
  {#if preview}
    <SeriesCardDisplay
      eventSeriesData={{
        ...eventSeriesData,
        owner: ownerName,
      }}
    />
  {:else}
    <a
      class="no-style"
      href="/series/{eventSeriesData.owner}/{eventSeriesData.identifier.id}"
    >
      <SeriesCardDisplay
        eventSeriesData={{
          ...eventSeriesData,
          owner: ownerName,
        }}
      />
    </a>
  {/if}
{/await}
