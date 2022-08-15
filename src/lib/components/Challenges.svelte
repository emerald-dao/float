<script>
  import { page } from "$app/stores";
  import Loading from "$lib/components/common/Loading.svelte";
  import SeriesList from "$lib/components/eventseries/SeriesList.svelte";
  import { getEventSeriesList } from "$lib/flow/actions";
  import { user } from "$lib/flow/stores";

  export let addressObject;
</script>

<article>
  <header class="text-center">
    <h3>Challenges</h3>
  </header>
  {#if !addressObject.address}
    <p>
      Invalid Address: {$page.params.address}
    </p>
  {:else}
    {#if $user?.addr == addressObject.address}
      <a href="/challenges/create" role="button" class="addnew">
        Create a new FLOAT Challenge
      </a>
    {/if}
    {#await getEventSeriesList(addressObject.address)}
      <Loading />
    {:then eventSeries}
      <SeriesList list={eventSeries} />
    {/await}
  {/if}
</article>

<style>
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
