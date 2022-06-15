<script>
    import { getStats } from "$lib/flow/actions";
    export let addition = 0;
</script>

{#await getStats() then stats}
<div class="grid info">
  <p>
    FLOATs Claimed<br />
    <span>{(parseInt(stats[0]) + addition).toLocaleString()}</span>
  </p>
  <p>Events Created<br />
    <span>{parseInt(stats[1]).toLocaleString()}</span>
  </p>
</div>
{/await}


<style>
  .info {
    margin-top: 30px;
    margin-bottom: 30px;
    text-align:center;
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