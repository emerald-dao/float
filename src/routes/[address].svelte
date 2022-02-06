<script>
  import { page } from '$app/stores';
  import { PAGE_TITLE_EXTENSION } from '$lib/constants'

  import CheckAddress from '$lib/components/CheckAddress.svelte';
  import { getFLOATEvents, getFLOATs } from '$lib/flow/actions.js'

  let floatEvents = getFLOATEvents($page.params.address);
  
  let floats = getFLOATs($page.params.address);
</script>

<style>
  article {
    margin-top:10px;
  }
</style>

<svelte:head>
	<title>FLOATs of {$page.params.address} { PAGE_TITLE_EXTENSION }</title>
</svelte:head>

<div class="container">
	<h1>Claimed FLOATs of {$page.params.address}</h1>

  <div class="grid">
    {#await floats}
      <h1>Loading...</h1>
    {:then floats} 
      {#each floats as float}
        <div>
          <img src="https://ipfs.infura.io/ipfs/{float.image}" alt="FLOAT Event" width="100px" height="100px" />
          <p>This FLOAT (serial #{float.serial}) was created by {float.host} for the `{float.name}` event.</p>
        </div>
      {/each}
    {/await}
  </div>

  <h1>Events by {$page.params.address}</h1>

  <div class="grid">
    {#await floatEvents}
      <h1>Loading...</h1>
    {:then floatEvents} 
      {#each Object.keys(floatEvents) as floatEventName}
        <a href="/claim/{$page.params.address}/{floatEvents[floatEventName].id}">
          <img src="https://ipfs.infura.io/ipfs/{floatEvents[floatEventName].image}" alt="FLOAT Event" width="100px" height="100px" />
          <p>Event name: {floatEvents[floatEventName].name}</p>
        </a>
      {/each}
    {/await}
  
  </div>

  <h2>Check another address</h2>

  <CheckAddress />
	
</div>

