<script>
  export let addressObject;
  import Loading from '$lib/components/common/Loading.svelte';
  import Float from '$lib/components/Float.svelte';
  import { getFLOATs } from '$lib/flow/actions.js'
  
  let floats = getFLOATs(addressObject.address);

</script>

<h3>Claimed FLOATs</h3>

<div class="card-container">
  {#await floats}
    <Loading />
  {:then floats} 
    {#if floats?.length > 0}
      {#each floats as float}
        <Float float={{totalSupply: float.totalSupply, transferrable: float.transferrable, ...float.float}} individual={true} />
      {/each}
    {:else}
      <p>This account doesn't have any FLOATs yet.</p>
    {/if}
  {/await}
</div>