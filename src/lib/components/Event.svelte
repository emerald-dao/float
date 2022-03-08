<script>
import { resolveAddressObject } from "$lib/flow/actions";
import Loading from "./common/Loading.svelte";

  async function getResolvedName() {
    let addressObject = await resolveAddressObject(floatEvent?.host);  
    if (addressObject.resolvedNames.find) {
      return addressObject.resolvedNames.find;
    }
    if (addressObject.resolvedNames.fn) {
      return addressObject.resolvedNames.fn;
    }
    return addressObject.address;
  }
  export let floatEvent = {};
  
  let resolvedName = getResolvedName();
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