<script context="module">
  import Pagination, {
    setLabels as _setPaginationLabels
  } from "./Pagination.svelte";
  import Row from "./Row.svelte";
  import Search, { setLabels as _setSearchLabels } from "./Search.svelte";
  import Sort, { setLabels as _setSortLabels } from "./Sort.svelte";
  export { Pagination, Row, Search, Sort };

  let globalLabels;

  export function setTableLabels(labels) {
    globalLabels = labels;
  }

  export const setPaginationLabels = _setPaginationLabels;
  export const setSearchLabels = _setSearchLabels;
  export const setSortLabels = _setSortLabels;
</script>

<script>
  import { createEventDispatcher, setContext } from "svelte";
  const dispatch = createEventDispatcher();

  export let loading = false;
  export let page = 0;
  export let pageIndex = 0;
  export let pageSize = 10;
  export let responsive = true;
  export let rows;
  export let serverSide = false;
  export let labels = {
    empty: "No records available",
    loading: "Loading data",
    ...globalLabels
  };

  let buttons = [-2, -1, 0, 1, 2];
  let pageCount = 0;

  $: filteredRows = rows;
  $: visibleRows = filteredRows.slice(pageIndex, pageIndex + pageSize);

  setContext("state", {
    getState: () => ({
      page,
      pageIndex,
      pageSize,
      rows,
      filteredRows
    }),
    setPage: (_page, _pageIndex) => {
      page = _page;
      pageIndex = _pageIndex;
    },
    setRows: _rows => (filteredRows = _rows)
  });

  function onPageChange(event) {
    dispatch("pageChange", event.detail);
  }

  function onSearch(event) {
    dispatch("search", event.detail);
  }
</script>


<style>
  /* .table {
    width: 100%;
    border-collapse: collapse;
  }

  .table :global(th), .table :global(td) {
    position: relative;
  } */

  .table {
    width: 100%;
    border-collapse: collapse;
  }

  .table :global(th), .table :global(td) {
    position: relative;
  }

  .center {
    text-align: center;
    font-style: italic;
  }

  .center > span {
    padding: 10px 10px;
    float: left;
    width: 100%;
  }

  .slot-top,
  .slot-bottom {
    float: left;
    width: 100%;
    margin-top: 1em;
  }

  @media screen and (max-width: 520px) {
    table.responsive {
      border: 0;
    }

    table.responsive :global(thead) {
      border: none;
      clip: rect(0 0 0 0);
      height: 1px;
      margin: -1px;
      overflow: hidden;
      padding: 0;
      position: absolute;
      width: 1px;
    }

    table.responsive :global(tr) {
      display: block;
      padding-bottom: 0.3em;
      margin-bottom: 0.3em;
      border-bottom: 1px solid var(--form-element-border-color);
    }

    table.responsive :global(td) {
      display: block;
      font-size: 0.8em;
      text-align: right;
    }

    table :global(.table-image) {
      max-width: 50px;
      max-height: 25px;
      display:inline;
    }

    table.responsive :global(td::before) {
      /*
	* aria-label has no advantage, it won't be read inside a table content: attr(aria-label);
	*/
      content: attr(data-label);
      float: left;
      font-weight: bold;
    }

    table.responsive :global(td[data-label-normal]::before) {
      font-weight: normal;
    }

    table.responsive :global(td[data-label-upper]::before) {
      text-transform: uppercase;
    }

    table.responsive :global(td:last-child),table.responsive :global(tr:last-child) {
      border-bottom: 0;
    }
  }

</style>

<slot name="top">
  <div class="slot-top">
    <svelte:component this={Search} on:search={onSearch} />
  </div>
</slot>

<table class={'table ' + $$props.class} class:responsive>
  <slot name="head" />
  {#if loading}
    <tbody>
      <tr>
        <td class="center" colspan="100%">
          <span>
            {@html labels.loading}
          </span>
        </td>
      </tr>
    </tbody>
  {:else if visibleRows.length === 0}
    <tbody>
      <tr>
        <td class="center" colspan="100%">
          <span>
            {@html labels.empty}
          </span>
        </td>
      </tr>
    </tbody>
  {:else}
    <slot rows={visibleRows} />
  {/if}
  <slot name="foot" />
</table>

<slot name="bottom">
  <div class="slot-bottom">
    <svelte:component
      this={Pagination}
      {page}
      {pageSize}
      {serverSide}
      count={filteredRows.length - 1}
      on:pageChange={onPageChange} />
  </div>
</slot>
