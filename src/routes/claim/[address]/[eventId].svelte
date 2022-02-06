<script>
  import { page } from '$app/stores';
  import { PAGE_TITLE_EXTENSION } from '$lib/constants'

  import CheckAddress from '$lib/components/CheckAddress.svelte';
  import { getFLOATEvent, claimFLOAT } from '$lib/flow/actions.js';

  let floatEvent = getFLOATEvent($page.params.address, $page.params.eventId);
  console.log(floatEvent);

  let claimCode = '';
</script>

<style>
  article {
    margin-top:10px;
  }
</style>

<svelte:head>
	<title>Claim {PAGE_TITLE_EXTENSION}</title>
</svelte:head>

<div class="container">
	<h1>Claim FLOAT #{$page.params.eventId}</h1>

  {#await floatEvent}
    <h1>Loading...</h1>
  {:then floatEvent}
    <h3>Name: {floatEvent.name}</h3>
    <img src="https://ipfs.infura.io/ipfs/{floatEvent.image}" alt="FLOAT Event" width="100" height="100" />
    <p>Description: {floatEvent.description}</p>
    <p>Ready to be claimed: {floatEvent.isOpen}</p>

    {#if floatEvent.isOpen}
      {#if floatEvent.requiresSecret}
        <label for="claimCode">Enter a claim code
          <input type="text" name="claimCode" bind:value={claimCode} placeholder="mySecretCode" />
        </label>
      {/if}
      <button on:click={() => claimFLOAT(floatEvent.host, floatEvent.id, claimCode)}>Claim this FLOAT</button>
    {/if}
  {/await}

  <h2>Check another address</h2>

  <CheckAddress />
	
</div>

