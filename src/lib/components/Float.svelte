<script>
  import UserAddress from '$lib/components/UserAddress.svelte'
  export let float = {}
  export let preview = false
</script>

{#if preview}
  <article class="card">
    <img src="https://ipfs.infura.io/ipfs/{float?.image}" alt="{float.name} Image" />
    <h1>{float?.name}</h1>
    <p>
      <small>
        <span class="credit">Created by</span>
        <a href="/{float?.host}" class="host">{float?.host}</a>
      </small>
    </p>
    <code>#{float?.totalSupply}</code>
  </article>
{:else}
  <a class="no-style" href="/{float?.host}/{float?.eventID}">
    <article class="card">
      <img src="https://ipfs.infura.io/ipfs/{float?.image}" alt="{float.name} Image" />
      <h1>{float?.name}</h1>
      <p>
        <small>
          <span class="credit">Created by</span>
          <a href="/{float?.host}" class="host">
            <UserAddress address={float?.host} simplify />
          </a>
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
    line-height: 1;
  }

  p {
    margin-top: 10px;
    margin-bottom: 10px;
  }
</style>
