<script>
  import UserAddress from '$lib/components/UserAddress.svelte'
  export let floatEvent = {}
</script>

<a class="no-style" href="/{floatEvent?.host}/{floatEvent?.id}">
  <article class="card">
    <img src="https://ipfs.infura.io/ipfs/{floatEvent?.image}" alt="{floatEvent.name} Image" />
    <h1>{floatEvent?.name}</h1>
    <p>
      <small>
        <span class="credit">Created by</span>
        <a href="/{floatEvent?.host}" class="host">
          <UserAddress address={floatEvent?.host} simplify />
        </a>
      </small>
    </p>
    <code class="mb-1">ID:{floatEvent?.id}</code>
    <button>Visit</button>
  </article>
</a>

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
