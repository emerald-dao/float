<script>
  import { getStats, getIncineratedStats } from "$lib/flow/actions";
  export let addition = 0;
  export let incinerator = false;
</script>

{#if incinerator}
  {#await getIncineratedStats() then stats}
    <div class="grid info">
      <p
        data-tooltip="The lower a FLOAT's serial and the longer you've had it, the more it adds to the flame.">
        Flame Strength<br />
        <span>{parseInt(stats[0]).toLocaleString()}</span>
      </p>
      <p>
        FLOATs Incinerated<br />
        <span>{(parseInt(stats[1]) + addition).toLocaleString()}</span>
      </p>
    </div>
  {/await}
{:else}
  {#await getStats() then stats}
    <div class="grid info">
      <p>
        FLOATs Claimed<br />
        <span>{(parseInt(stats[0]) + addition).toLocaleString()}</span>
      </p>
      <p>
        Events Created<br />
        <span>{parseInt(stats[1]).toLocaleString()}</span>
      </p>
    </div>
  {/await}
{/if}

<style>
  p {
    border-bottom: none;
  }

  .info {
    margin-top: 30px;
    margin-bottom: 30px;
    text-align: center;
  }
  .info p {
    line-height: 1.1;
    font-size: 0.8rem;
  }

  .info span {
    color: var(--contrast);
    font-size: 2.3rem;
    font-weight: 900;
  }
</style>
