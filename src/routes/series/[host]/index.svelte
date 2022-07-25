<script>
  import { page } from "$app/stores";
  import Meta from "$lib/components/common/Meta.svelte";
  import Loading from "$lib/components/common/Loading.svelte";
  import SeriesList from "$lib/components/eventseries/SeriesList.svelte";
  import { getEventSeries, resolveAddressObject } from "$lib/flow/actions";
  import { user } from "$lib/flow/stores";

  let loadFloatEventSeries = async (address) => {
    const rawDic = await getEventSeries(address);
    if (rawDic && Object.keys(rawDic)?.length > 0) {
      return Object.values(rawDic);
    } else {
      return [];
    }
  };
</script>

<Meta
  title="EventSeries hosted by {$page.params.host}"
  author={$page.params.host}
  description="EventSeries hosted by {$page.params.host}"
  url={$page.url}
  removeTitleSuffix={true}
/>

<article>
  <header class="text-center">
    <h3>Event Series</h3>
    <span class="address-hint">by {$page.params.host}</span>
  </header>
  {#await resolveAddressObject($page.params.host)}
    <Loading />
  {:then addressObject}
    {#if $user?.addr == addressObject.address}
      <a href="/series/create" role="button" class="addnew">
        Create a new FLOAT EventSeries
      </a>
    {/if}
    {#await loadFloatEventSeries(addressObject.address)}
      <Loading />
    {:then eventSeries}
      <SeriesList
        list={eventSeries.map((item) => ({
          sequence: item.sequence ? parseInt(item.sequence) : -1,
          identifier: {
            host: addressObject.address,
            id: item.id,
          },
          basics: {
            name: item.display?.name,
            description: item.display?.description,
            image: item.display?.thumbnail?.cid ?? "",
          },
          slots: item.slots || [],
        }))}
      />
    {/await}
  {/await}
</article>

<style>
  .address-hint {
    font-size: 0.8rem;
    font-weight: lighter;
  }

  .addnew {
    font-weight: bold;
    width: 100%;
    margin-bottom: 20px;
  }

  @media screen and (max-width: 767px) {
    .addnew {
      margin-top: 20px;
    }
  }
</style>
