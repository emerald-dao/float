<script>
  export let floatEvent = {};
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


<a class="no-style" href="/{floatEvent?.host}/{floatEvent?.eventId}">
  <article class="card">
    {#if floatEvent?.image}
    <img src="https://ipfs.infura.io/ipfs/{floatEvent?.image}" alt="{floatEvent.name} Image" />
    {/if}
    <h1>{floatEvent?.name}</h1>
    <p>
      <small>
        <span class="credit">Created by</span>
        <a href="/{floatEvent?.host}" class="host">{floatEvent?.host}</a>
      </small>
    </p>
    <code class="mb-1">ID:{floatEvent?.eventId}</code>
    <button>Visit</button>
  </article>
</a>