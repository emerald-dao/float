<script context="module">
  let globalLabels;

  export function setLabels(labels) {
    globalLabels = labels;
  }
</script>

<script>

  // pass true for more controls
  import { createEventDispatcher, getContext } from "svelte";
  const dispatch = createEventDispatcher();
  const stateContext = getContext("state");
  
  export let complete = true;
  export let buttons = [-2, -1, 0, 1, 2];
  export let count;
  export let page = 0;
  export let pageSize;
  export let serverSide = false;

  export let labels = {
    first: "⇤",
    last: "⇥",
    next: "→",
    previous: "←",
    ...globalLabels
  };

  $: pageCount = Math.floor(count / pageSize);

  function onChange(event, page) {
    const state = stateContext.getState();
    const detail = {
      originalEvent: event,
      page,
      pageIndex: serverSide ? 0 : page * state.pageSize,
      pageSize: state.pageSize
    };
    dispatch("pageChange", detail);

    if (detail.preventDefault !== true) {
      stateContext.setPage(detail.page, detail.pageIndex);
    }
  }
</script>

<style>
  div {
    display:flex;
  }

  button {
    margin-left: 5px;
    font-size: 0.8rem;
    padding: 0.5rem 0.5rem;
  }

  /* button {
    background: transparent;
    border: 1px solid #ccc;
    padding: 5px 10px;
    margin-left: 3px;
    float: left;
    cursor: pointer;
  } */
</style>

<div>

  {#if complete}
    <button class="outline" disabled={page === 0} on:click={e => onChange(e, 0)}>
      {labels.first}
    </button>
  {/if}

    <button class="outline" disabled={page === 0} on:click={e => onChange(e, page - 1)}>
      {labels.previous}
    </button>
  {#if complete}
  {#each buttons as button}
    {#if page + button >= 0 && page + button <= pageCount}
    
        <button
          class:outline={page !== page + button}
          on:click={e => onChange(e, page + button)}>
          {page + button + 1}
        </button>
    
    {/if}
  {/each}
  {/if}
    <button
      class="outline"
      disabled={page > pageCount - 1}
      on:click={e => onChange(e, page + 1)}>
      {labels.next}
    </button>

  {#if complete}
    <button class="outline" disabled={page >= pageCount} on:click={e => onChange(e, pageCount)}>
      {labels.last}
    </button>
  {/if}
</div>
