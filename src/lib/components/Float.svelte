<script>
  import { resolveAddressObject } from "$lib/flow/actions";
  import { getResolvedName } from "$lib/flow/utils";

  export let float = {};
  export let preview = false;
  export let individual = false;
  export let list = true;

  async function initialize() {
    let addressObject = await resolveAddressObject(float.eventHost);  
    return getResolvedName(addressObject);
  }
  
  let resolvedName = initialize();

</script>

{#await resolvedName then resolvedName}
  {#if individual}
    <a
      class="no-style"
      href="/{resolvedName}/{float.eventId}/{float.serial}">
      <article class="card" class:nomargin={!list}>
        <img
          src="https://ipfs.infura.io/ipfs/{float.eventImage}"
          alt="{float.eventName} Image" />
        <h1>{float.eventName}</h1>
        <p>
          <small>
            <span class="credit">Created by</span>
            <a href="/{resolvedName}" class="host">{resolvedName}</a>
          </small>
        </p>
        <code data-tooltip="{float.serial} of {float.totalSupply}"
          >#{float.serial}</code>
      </article>
    </a>
  {:else if preview}
    <article class="card card-preview">
      {#if float.eventImage}
        <img
          src="https://ipfs.infura.io/ipfs/{float.eventImage}"
          alt="{float.eventName} Image" />
      {/if}
      <h1>{float.eventName}</h1>
      <p>
        <small>
          <span class="credit">Created by</span>
          <a href="/{resolvedName}" class="host">{resolvedName}</a>
        </small>
      </p>
      <code data-tooltip="Minted so far"
        >#{float.totalSupply}</code>
    </article>
  {:else}
    <a class="no-style" href="/{resolvedName}/{float.eventId}">
      <article class="card">
        {#if float.eventImage}
          <img
            src="https://ipfs.infura.io/ipfs/{float.eventImage}"
            alt="{float.eventName} Image" />
        {/if}
        <h1>{float.eventName}</h1>
        <p>
          <small>
            <span class="credit">Created by</span>
            <a href="/{resolvedName}" class="host">{resolvedName}</a>
          </small>
        </p>
        <code data-tooltip="{float.serial} of {float.totalSupply}"
          >#{float.serial}</code>
      </article>
    </a>
  {/if}
{/await}

<style>
  .host {
    font-family: monospace;
  }

  .credit {
    font-size: 0.7rem;
    display: block;
    line-height: 1;
  }

  p {
    margin-top: 10px;
    margin-bottom: 10px;
  }

  .nomargin {
    margin-right: 0px;
  }
</style>
