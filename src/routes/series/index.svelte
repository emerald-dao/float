<script>
  import { PAGE_TITLE_EXTENSION } from "$lib/constants";
  import Pagination from "$lib/components/common/table/Pagination.svelte";
  import Loading from "$lib/components/common/Loading.svelte";
  import SeriesList from "$lib/components/eventseries/SeriesList.svelte";
  import { setContext } from "svelte";
  import { user } from "$lib/flow/stores";
  import { authenticate, getGlobalEventSeriesList } from "$lib/flow/actions";

  let page = 0;
  let pageIndex = 0;
  let pageSize = 20;
  let withTreasury = true;

  $: promise = getGlobalEventSeriesList(page, pageSize, withTreasury);

  setContext("state", {
    getState: () => ({
      page,
      pageIndex,
      pageSize,
    }),
    setPage: (_page, _pageIndex) => {
      page = _page;
      pageIndex = _pageIndex;
    },
  });
</script>

<svelte:head>
  <title>Event Series {PAGE_TITLE_EXTENSION}</title>
</svelte:head>

<article>
  <header class="text-center">
    <h3>FLOAT Event Series</h3>
  </header>
  <label for="withTreasury">
    <input
      type="checkbox"
      id="withTreasury"
      name="withTreasury"
      role="switch"
      bind:checked={withTreasury}
    />
    Treasury available
  </label>
  {#await promise}
    <Loading />
  {:then result}
    <SeriesList list={result.list} />
    <div class="mb-1">
      <Pagination {page} {pageSize} count={result.total ?? 0} />
    </div>
  {/await}

  {#if $user?.addr}
    <a href="/series/create" role="button" class="addnew">
      Create a new FLOAT EventSeries
    </a>
  {:else}
    <button class="contrast small-button" on:click={authenticate}>
      Connect Wallet
    </button>
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
