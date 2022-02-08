<script>
  import UserAddress from '$lib/components/UserAddress.svelte'
  export let float = {}
  export let preview = false
</script>

{#if preview}
  <article class="card">
    <img
      src="https://ipfs.infura.io/ipfs/{float?.eventMetadata.image}"
      alt="{float?.eventMetadata.name} Image"
    />
    <h1>{float?.eventMetadata.name}</h1>
    <p>
      <small>
        <span class="credit">Created by</span>
        <!-- <a href="/{float?.eventHost}" class="host">{float?.eventHost}</a> -->
        <UserAddress address={float?.eventHost} simplify />

      </small>
    </p>
    <code>#{float?.eventMetadata.totalSupply}</code>
  </article>
{:else}
  <a class="no-style" href="/{float?.eventHost}/{float?.eventId}">
    <article class="card">
      <img
        src="https://ipfs.infura.io/ipfs/{float?.eventMetadata.image}"
        alt="{float?.eventMetadata.name} Image"
      />
      <h1>{float?.eventMetadata.name}</h1>
      <p>
        <small>
          <span class="credit">Created by</span>
          <!-- <a href="/{float?.eventHost}" class="host">{float?.eventHost}</a> -->
          <UserAddress address={float?.eventHost} simplify />

        </small>
      </p>
      <code>#{float?.serial}</code>
    </article>
  </a>
{/if}

<style>
  .host {
    font-family: monospace;
  }

  .credit {
    display: block;
    font-size: 0.7rem;
    display: block;
    line-height: 1;
  }

  p {
    margin-top: 10px;
    margin-bottom: 10px;
  }
</style>
