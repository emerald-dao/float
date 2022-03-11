<script>
  export let addressObject;
  import Loading from '$lib/components/common/Loading.svelte';
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