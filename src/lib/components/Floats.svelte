<script>
  export let addressObject;
  import Loading from '$lib/components/common/Loading.svelte';
  import Float from '$lib/components/Float.svelte';
  import FloatsTable from '$lib/components/common/table/FloatsTable.svelte';
  import { getFLOATs } from '$lib/flow/actions.js'
  
  let floats = getFLOATs(addressObject.address);
  
</script>



<article>
  <header>
    <h3 class="text-center">Claimed FLOATs</h3>
  </header>
  {#await floats}
  <Loading />
  {:then floats} 
  <FloatsTable floats={Object.values(floats || {})?.map(obj => obj.float)} />
  {/await}
</article>
  
  <!-- <div class="card-container">
    {#await floats}
    <Loading />
    {:then floats} 
    
    <FloatsTable floats={Object.values(floats || {})?.map(obj => obj.float)} />
      
      {#if floats?.length > 0}
      {#each floats as float}
      <Float float={{totalSupply: float.totalSupply, transferrable: float.transferrable, ...float.float}} individual={true} />
      {/each}
      {:else}
      <p>This account doesn't have any FLOATs yet.</p>
      {/if}
      {/await}
    </div> -->