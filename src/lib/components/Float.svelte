<script>
  import { resolveAddressObject } from "$lib/flow/actions";
  import { getResolvedName } from "$lib/flow/utils";

  export let float = {};
  export let claimed = false;

  let eventHostObject;
  let eventHostResolvedName;

  let ownerObject;
  let ownerResolvedName;
  async function initialize() {
    eventHostObject = await resolveAddressObject(float.eventHost);  
    eventHostResolvedName = getResolvedName(eventHostObject);

    if (float.owner) {
      ownerObject = await resolveAddressObject(float.owner);  
      ownerResolvedName = getResolvedName(ownerObject);
    }
    return "";
  }
  
  let resolvedName = initialize();

</script>

{#await resolvedName then resolvedName}
  {#if claimed}
    <a
      class="no-style"
      href="/{ownerResolvedName}/float/{float.id}">
      <article class="card">
        <img
          src="https://ipfs.infura.io/ipfs/{float.eventImage}"
          alt="{float.eventName} Image" />
        <h1>{float.eventName}</h1>
        <p>
          <small>
            <span class="credit">Created by</span>
            <a href="/{eventHostResolvedName}" class="host">{eventHostResolvedName}</a>
          </small>
        </p>
        <code data-tooltip="{float.serial} of {float.totalSupply}"
          >#{float.serial}</code>
      </article>
    </a>
  {:else}
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
          <a href="/{eventHostResolvedName}" class="host">{eventHostResolvedName}</a>
        </small>
      </p>
      <code data-tooltip="Minted so far"
        >#{float.totalSupply}</code>
    </article>
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
