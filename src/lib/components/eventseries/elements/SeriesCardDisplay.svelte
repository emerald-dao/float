<script>
  import { t } from "svelte-i18n";
  /** @type {import('../types').EventSeriesData} */
  export let eventSeriesData = {};
</script>

<article class="card-wrapper">
  <div class="card">
    {#if eventSeriesData.basics?.image}
      <img
        src="https://ipfs.io/ipfs/{eventSeriesData.basics?.image}"
        alt="{eventSeriesData.basics?.name} Image"
      />
    {/if}
  </div>
  <div class="card-content">
    <h1>{eventSeriesData.basics?.name}</h1>
    <div class="desc">
      {eventSeriesData.basics?.description}
    </div>
    <div class="flex-wrap flex-gap">
      <code
        data-tooltip={$t("challenges.elements.card.slot-tip", {
          values: {
            n: eventSeriesData.slots?.length ?? 0,
          },
        })}
        class="flex-none"
      >
        {$t("challenges.elements.card.slot", {
          values: {
            n: eventSeriesData.slots?.length ?? 0,
          },
        })}
      </code>
      {#if eventSeriesData.owner}
        <small class="flex-auto">
          <span class="credit">
            {$t("challenges.elements.card.created-by")}
          </span>
          <a
            href="/{eventSeriesData.owner}/?tab=challenges"
            target="_blank"
            class="host"
          >
            {eventSeriesData.owner}
          </a>
        </small>
      {/if}
    </div>
  </div>
</article>

<style>
  .card-wrapper {
    display: flex;
    justify-items: center;
    align-items: flex-start;
    padding: 0;
    width: 100%;
    border: 1px solid transparent;
  }

  @media screen and (max-width: 520px) {
    .card-wrapper {
      flex-wrap: wrap;
    }
  }

  .card-wrapper:hover {
    border: 1px solid var(--primary);
  }

  .card-wrapper .desc:last-child {
    margin-bottom: 0;
  }

  .card-wrapper > .card {
    flex: none;
    border-width: 0px;
    margin: 0;
    padding: 1rem;
  }
  .card-wrapper > .card img {
    margin-bottom: 0px;
  }

  .card-wrapper > .card-content {
    flex: 1 1 auto;
    padding: 1rem 0.5rem;
  }

  .card-content h1 {
    margin-top: 10px;
    margin-bottom: 10px;
    font-size: 1.3rem;
    flex-grow: 1;
    word-break: break-all;
  }

  .card-content .desc {
    min-height: 72px;
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
