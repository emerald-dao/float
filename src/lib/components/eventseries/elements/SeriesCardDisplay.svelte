<script>
  /** @type {import('../types').EventSeriesData} */
  export let eventSeriesData = {};
</script>

<article class="panel">
  <div class="card">
    {#if eventSeriesData.basics?.image}
      <img
        src="https://ipfs.infura.io/ipfs/{eventSeriesData.basics?.image}"
        alt="{eventSeriesData.basics?.name} Image"
      />
    {/if}
    {#if eventSeriesData.owner}
      <p>
        <small>
          <span class="credit">Created by</span>
          <a href="/series/{eventSeriesData.owner}" class="host">
            {eventSeriesData.owner}
          </a>
        </small>
      </p>
    {/if}
  </div>
  <div class="panel-content">
    <h1>{eventSeriesData.basics?.name}</h1>
    <p>
      {eventSeriesData.basics?.description}
    </p>
    <code data-tooltip="Total slots">
      FLOAT Slots: {eventSeriesData.slots?.length ?? 0}
    </code>
  </div>
</article>

<style>
  .panel {
    display: flex;
    justify-items: center;
    align-items: flex-start;
    padding: 0;
    width: 100%;
    border: 1px solid transparent;
  }

  .panel:hover {
    border: 1px solid var(--primary);
  }

  .panel p:last-child {
    margin-bottom: 0;
  }

  .panel > .card {
    flex: none;
    border-width: 0px;
    margin: 0;
  }

  .panel > .panel-content {
    flex: 1 1 auto;
    padding: 1rem 0.5rem;
  }

  .panel-content h1 {
    margin-top: 10px;
    margin-bottom: 10px;
    font-size: 1.3rem;
    flex-grow: 1;
    word-break: break-all;
  }

  .panel-content p {
    min-height: 80px;
    overflow-wrap: break-word;
  }

  .host {
    font-family: monospace;
  }

  .credit {
    font-size: 0.7rem;
    display: block;
    line-height: 1;
  }
</style>
