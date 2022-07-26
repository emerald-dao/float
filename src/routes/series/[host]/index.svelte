<script>
  import { page } from "$app/stores";
  import Meta from "$lib/components/common/Meta.svelte";
  import Loading from "$lib/components/common/Loading.svelte";
  import SeriesList from "$lib/components/eventseries/SeriesList.svelte";
  import { getEventSeriesList, resolveAddressObject } from "$lib/flow/actions";
  import { user } from "$lib/flow/stores";
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
    {#if !addressObject.address}
      <p>
        Invalid Address: {$page.params.host}
      </p>
    {:else}
      {#if $user?.addr == addressObject.address}
        <a href="/series/create" role="button" class="addnew">
          Create a new FLOAT EventSeries
        </a>
      {/if}
      {#await getEventSeriesList(addressObject.address)}
        <Loading />
      {:then eventSeries}
        <SeriesList list={eventSeries} />
      {/await}
    {/if}
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
