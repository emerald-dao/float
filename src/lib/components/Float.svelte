<script>
  import { resolveAddressObject } from "$lib/flow/actions";
  import { getResolvedName } from "$lib/flow/utils";

  export let float = {};
  export let claimed = false;
  export let smaller = false;

  let eventHostObject;
  let eventHostResolvedName;

  async function initialize() {
    eventHostObject = await resolveAddressObject(float.eventHost);
    eventHostResolvedName = getResolvedName(eventHostObject);
    return "";
  }

  let resolvedName = initialize();
</script>

{#await resolvedName then resolvedName}
  {#if claimed}
    <a class="no-style" href="/{float.owner}/float/{float.id}">
      <article class="card">
        <img
          src="https://ipfs.infura.io/ipfs/{float.eventImage}"
          alt="{float.eventName} Image" />
        <h1>{float.eventName}</h1>
        <p>
          <small>
            <span class="credit">Created by</span>
            <a href="/{eventHostResolvedName}" class="host"
              >{eventHostResolvedName}</a>
          </small>
        </p>
        <code data-tooltip="{float.serial} of {float.totalSupply}"
          >#{float.serial}</code>
      </article>
    </a>
  {:else}
    <article class="card card-preview" class:smaller>
      {#if float.eventImage}
        <img
          class:smaller
          src="https://ipfs.infura.io/ipfs/{float.eventImage}"
          alt="{float.eventName} Image" />
      {/if}
      <h1 class:smaller>{float.eventName}</h1>
      <p>
        <small class:smaller>
          <span class="credit">Created by</span>
          <a href="/{eventHostResolvedName}" class="host"
            >{eventHostResolvedName}</a>
        </small>
      </p>
      <code data-tooltip="Minted so far" class:smaller
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

  img.smaller {
    width: 50px;
    height: 50px;
  }

  h1.smaller {
    font-size: 16px;
  }

  article.smaller {
    margin: 5px;
  }

  small.smaller,
  code.smaller {
    font-size: 14px;
  }
</style>
