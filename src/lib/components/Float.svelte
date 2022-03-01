<script>
  export let float = {};
  export let preview = false;
  export let individual = false;

  console.log(float);
</script>

{#if individual}
  <a
    class="no-style"
    href="/{float?.eventHost}/{float?.eventId}/{float?.serial}"
  >
    <article class="card">
      <img
        src="https://ipfs.infura.io/ipfs/{float?.eventImage}"
        alt="{float?.eventName} Image"
      />
      <h1>{float?.eventName}</h1>
      <p>
        <small>
          <span class="credit">Created by</span>
          <a href="/{float?.eventHost}" class="host">{float?.eventHost}</a>
        </small>
      </p>
      <code data-tooltip="{float?.serial} of {float?.eventMetadata.totalSupply}">#{float?.serial}</code>
    </article>
  </a>
{:else if preview}
  <article class="card card-preview">
    {#if float?.eventImage}
    <img
      src="https://ipfs.infura.io/ipfs/{float?.eventImage}"
      alt="{float?.eventName} Image"
    />
    {/if}
    <h1>{float?.eventName}</h1>
    <p>
      <small>
        <span class="credit">Created by</span>
        <a href="/{float?.eventHost}" class="host">{float?.eventHost}</a>
      </small>
    </p>
    <code data-tooltip="Minted so far">#{float?.eventMetadata.totalSupply}</code>
  </article>
{:else}
  <a class="no-style" href="/{float?.eventHost}/{float?.eventId}">
    <article class="card">
      {#if float?.eventImage}
      <img
        src="https://ipfs.infura.io/ipfs/{float?.eventImage}"
        alt="{float?.eventName} Image"
      />
      {/if}
      <h1>{float?.eventName}</h1>
      <p>
        <small>
          <span class="credit">Created by</span>
          <a href="/{float?.eventHost}" class="host">{float?.eventHost}</a>
        </small>
      </p>
      <code data-tooltip="{float?.serial} of {float?.eventMetadata.totalSupply}">#{float?.serial}</code>
    </article>
  </a>
{/if}

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
</style>
