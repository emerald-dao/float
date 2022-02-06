<script>
  import { page } from '$app/stores';
  import { user } from "$lib/flow/stores";
  import { PAGE_TITLE_EXTENSION } from '$lib/constants'
  import { getFLOATEvent, claimFLOAT } from '$lib/flow/actions.js';
  import Loading from '$lib/components/common/Loading.svelte';
  import Float from '$lib/components/Float.svelte';
  import Countdown from '$lib/components/common/Countdown.svelte';
  
  let floatEvent = getFLOATEvent($page.params.address, $page.params.eventId);
  console.log(floatEvent);
  
  let claimCode = '';

  $: currentUnixTime = +new Date() / 1000;
</script>

<svelte:head>
<title>Claim {PAGE_TITLE_EXTENSION}</title>
</svelte:head>

<style>
  .container {
    text-align:center;
  }
  blockquote {
    text-align: left;
  }

  .secondary.outline {
    font-weight: 300;
  }

  .emphasis {
    font-weight: 400;
    color: var(--primary)
  }

  p {
    margin-bottom: 0px;
  }
</style>
<div class="container">
  
  
  
  
  {#await floatEvent}
  <Loading />
  {:then floatEvent}
  <article>
    <header>
      <a href="{floatEvent?.url}" target="_blank"><h1>FLOAT Event #{$page.params.eventId}</h1></a>
      <p>Created on {new Date(floatEvent?.dateCreated * 1000).toLocaleString()}</p>
    </header>
    <Float float={floatEvent} preview={true} />
    
    <blockquote>{floatEvent?.description}</blockquote>
    <p><span class="emphasis">{floatEvent?.totalSupply}</span> have been minted.</p>
    {#if floatEvent?.capacity}
      <p>Only <span class="emphasis">{floatEvent.capacity}</span> will ever exist.</p>
    {/if}
    <footer>

      <!-- 
        Possible cases:
        - not claimable -> host needs to manually assign
        - claimable
          - secret code -> Add secrete code + "Claim"
          - no secret code -> "Claim"
        - claimable and not open
          - time not started -> "Claimable in .... days"
          - time expired -> "This FLOAT is closed"
          - capacity reached -> "This FLOAT is closed. All 1000/1000 have been claimed"
      -->
      
      {#if Object.keys(floatEvent?.claimed).includes($user?.addr)}
        <button class="secondary" disabled>You have already claimed this FLOAT.</button>
      {:else if floatEvent?.claimable}
        {#if floatEvent?.isOpen && !floatEvent?.requiresSecret}
          <button on:click={() => claimFLOAT(floatEvent?.host, floatEvent?.id, claimCode)}>Claim this FLOAT</button>
        {:else if floatEvent?.isOpen}
          <label for="claimCode">Enter the claim code below.
            <input type="text" name="claimCode" bind:value={claimCode} placeholder="secret code" />
          </label>
          {#if claimCode === ''}
            <button class="secondary outline" disabled>You must enter a secret code.</button>
          {:else}
            <button on:click={() => claimFLOAT(floatEvent?.host, floatEvent?.id, claimCode)}>Claim this FLOAT</button>
          {/if}
        {:else if floatEvent?.capacity && floatEvent?.capacity <= floatEvent?.currentCapacity}
        <button class="secondary outline" disabled>This FLOAT is no longer available.<br/> All <span class="emphasis">{ floatEvent?.currentCapacity}/{floatEvent?.capacity}</span> have been claimed.</button>
        {:else if floatEvent?.startTime > currentUnixTime}
        <button class="secondary outline" disabled>
            This FLOAT Event has not started yet.<br/>
            Starting in <span class="emphasis"><Countdown unix={floatEvent?.startTime} /></span>
        </button>
        {:else if floatEvent?.endTime < currentUnixTime}
        <button class="secondary outline" disabled>This FLOAT is no longer available.<br/>This event has ended.</button>
        {:else}
        <button class="secondary outline" disabled>This FLOAT is not claimable.<br/>Unknown reason.</button>
        {/if}
      {:else}
        <button class="secondary outline" disabled>This FLOAT is not claimable.<br/>The host opted to distribute it manually.</button>
      {/if}
    </footer>
  </article>
  {/await}

  
</div>

