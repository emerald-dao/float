<script>
  import { resolveAddressObject } from "$lib/flow/actions";
  import { getResolvedName } from "$lib/flow/utils";
  import Loading from "./common/Loading.svelte";

  export let floatEvent = {};
  async function initialize() {
    let addressObject = await resolveAddressObject(floatEvent?.host);  
    return getResolvedName(addressObject);
  }
  
  let resolvedName = initialize();
</script>

<style>

  .host {
    font-family: monospace;
  }

  .credit {
    font-size: 0.7rem;
    display:block;
    line-height: 1;
  }

  p {
    margin-top: 10px;
    margin-bottom: 10px;
  }
</style>

{#await resolvedName}
  <Loading />
{:then resolvedName}
  <a class="no-style" href="/{resolvedName}/{floatEvent?.eventId}">
    <article class="card">
      {#if floatEvent?.image}
      <img src="https://ipfs.infura.io/ipfs/{floatEvent?.image}" alt="{floatEvent.name} Image" />
      {/if}
      <h1>{floatEvent?.name}</h1>
      <p>
        <small>
          <span class="credit">Created by</span>
          <a href="/{resolvedName}" class="host">{resolvedName}</a>
        </small>
      </p>
      <code class="mb-1">ID:{floatEvent?.eventId}</code>
      <button>Visit</button>
    </article>
  </a>
{/await}